import os
import sys
import json

from config.io import parse_yaml_string
from tui.terminal import prompt_numeric_menu, notify_user, open_in_editor
from jira.client import (
    search_jira,
    update_issue,
    fetch_transitions,
    fetch_active_sprint,
    add_to_sprint,
)

from tui.formatters import clean_issue_key
from jira.markdown import adf_to_markdown, split_frontmatter_and_body, markdown_to_adf
from jira.payloads import (
    build_search_payload,
    parse_search_response,
    build_upsert_payload,
    build_transition_payload,
)
from constants import C


def generate_schema(cache_dir, cfg, board_slug, board_cfg):
    """Pure-ish: Generates the JSON Schema for the YAML language server dynamically."""
    schema_path = os.path.join(cache_dir, f"frontmatter.{board_slug}.schema.json")
    types = [t["name"] for t in cfg.get("types", [])]
    transitions = board_cfg.get("transitions", [])

    properties = {
        "key": {"type": "string"},
        "summary": {"type": "string"},
        "type": {"type": "string", "enum": types},
        "priority": {
            "type": "string",
            "enum": ["Highest", "High", "Medium", "Low", "Lowest"],
        },
        "status": {"type": "string", "enum": transitions}
        if transitions
        else {"type": "string"},
        "parent": {"type": "string"},
        "sprint": {"type": "boolean"},
    }

    for cf_name in cfg.get("custom_fields", {}).keys():
        if cf_name == "team":
            properties["team"] = {"type": "boolean"}
        else:
            properties[cf_name] = {"type": "string"}

    schema = {
        "$schema": "http://json-schema.org/draft-07/schema#",
        "type": "object",
        "properties": properties,
        "required": ["summary", "type"],
    }

    with open(schema_path, "w") as f:
        json.dump(schema, f, indent=2)

    return schema_path


def execute_upsert(args, server, token, cfg):
    """The Imperative Shell for the edit/create story."""
    editor_cmd = cfg.get("editor") or os.environ.get("EDITOR", "vim")

    summary_val = ""
    board_slug = None
    clean_args = []

    skip_next = False
    for i, arg in enumerate(args):
        if skip_next:
            skip_next = False
            continue
        if arg in ("-s", "--summary"):
            summary_val = args[i + 1] if i + 1 < len(args) else ""
            skip_next = True
        elif arg in ("-b", "--board"):
            board_slug = args[i + 1] if i + 1 < len(args) else None
            skip_next = True
        else:
            clean_args.append(arg)

    is_edit = "--edit" in clean_args
    is_dry_run = "--dry-run" in clean_args
    use_toast = "--toast" in clean_args

    if not board_slug:
        board_slug = cfg.get("default_board", "ci")

    board_cfg = cfg.get("boards", {}).get(board_slug, {})
    project_key = board_cfg.get("project_key")

    cache_dir = os.path.expanduser("~/.local/state/j/cache")
    schema_path = generate_schema(cache_dir, cfg, board_slug, board_cfg)
    schema_header = f"# yaml-language-server: $schema=file://{schema_path}\n"

    current_status = None

    # ==========================================
    # 1. SETUP & FETCH
    # ==========================================
    if is_edit:
        positionals = [a for a in clean_args if not a.startswith("--")]
        if not positionals:
            notify_user("Issue key required for edit.", "Error", use_toast)
            sys.exit(1)

        clean_key = clean_issue_key(positionals[-1])
        jql = f"key = {clean_key}"

        search_payload = build_search_payload(
            jql, cfg.get("formatted_custom_fields", {})
        )
        raw_response = search_jira(server, token, search_payload)
        issues, _, _ = parse_search_response(raw_response)

        if not issues:
            notify_user(f"Could not find issue {clean_key}", "Edit Error", use_toast)
            sys.exit(1)

        fields = issues[0].get("fields", {})

        current_type = fields.get("issuetype", {}).get("name", "")
        current_summary = summary_val if summary_val else fields.get("summary", "")
        current_status = fields.get("status", {}).get("name", "")
        current_priority = fields.get("priority", {}).get("name", "Medium")
        current_parent = fields.get("parent", {}).get("key", "")

        md_desc = adf_to_markdown(fields.get("description")).strip()

        custom_fields_yaml = ""
        for cf_name, cf_id in cfg.get("custom_fields", {}).items():
            if cf_name == "team":
                custom_fields_yaml += "team: true\n"
            else:
                val = fields.get(f"customfield_{cf_id}")
                if val:
                    if isinstance(val, dict):
                        val = val.get("value", "") or val.get("name", "")
                    custom_fields_yaml += f'{cf_name}: "{val}"\n'

        # Only insert parent if it actually exists
        parent_yaml = f'parent: "{current_parent}"\n' if current_parent else ""

        initial_doc = (
            f"---\n"
            f"{schema_header}"
            f"key: {clean_key}\n"
            f'type: "{current_type}"\n'
            f'priority: "{current_priority}"\n'
            f'status: "{current_status}"\n'
            f"{parent_yaml}"
            f"{custom_fields_yaml}"
            f'summary: "{current_summary}"\n'
            f"---\n\n"
            f"{md_desc}"
        )
    else:
        types = [t["name"] for t in cfg.get("types", [])]
        choice_idx = prompt_numeric_menu(types, "CREATE NEW ISSUE", color=C["green"])
        if choice_idx is None:
            sys.exit(0)

        selected_type = types[choice_idx]
        type_cfg = next(
            (t for t in cfg.get("types", []) if t["name"] == selected_type), {}
        )
        template_body = type_cfg.get("template", "").strip()

        custom_fields_yaml = (
            "team: true\n" if "team" in cfg.get("custom_fields", {}) else ""
        )

        initial_doc = (
            f"---\n"
            f"{schema_header}"
            f'type: "{selected_type}"\n'
            f'priority: "Medium"\n'
            f'status: "Backlog"\n'
            f"{custom_fields_yaml}"
            f'summary: "{summary_val}"\n'
            f"---\n\n"
            f"{template_body}"
        )

    # ==========================================
    # 2. USER INTERACTION
    # ==========================================
    target_line = None
    search_pattern = None

    if summary_val:
        lines = initial_doc.split("\n")
        dash_count = 0
        for idx, line in enumerate(lines):
            if line.strip() == "---":
                dash_count += 1
                if dash_count == 2:
                    target_line = idx + 2
                    break
    else:
        search_pattern = "^summary:"

    raw_modified_doc = open_in_editor(
        editor_cmd, initial_doc, target_line=target_line, search_pattern=search_pattern
    )

    # ==========================================
    # 3. IDEMPOTENCY CHECK
    # ==========================================
    # If the user saved and quit without changing a single character, cleanly exit.
    if raw_modified_doc.strip() == initial_doc.strip():
        print(
            f"\n{C['dim']}No changes detected. Skipping update.{C['reset']}"
        ) if is_dry_run else notify_user("No changes made.", "Skipped", use_toast)
        sys.exit(0)

    # ==========================================
    # 4. PARSING & TRANSFORMATION
    # ==========================================
    yaml_str, md_body = split_frontmatter_and_body(raw_modified_doc)
    frontmatter_dict = parse_yaml_string(yaml_str)

    if not frontmatter_dict or not frontmatter_dict.get("summary"):
        notify_user("Aborted: Summary is required.", "Upsert Cancelled", use_toast)
        sys.exit(1)

    adf_body = markdown_to_adf(md_body)

    issue_key = frontmatter_dict.get("key")
    pk_to_pass = None if issue_key else project_key
    team_uuid = board_cfg.get("team_uuid")

    upsert_payload = build_upsert_payload(
        frontmatter_dict,
        adf_body,
        cfg.get("types", []),
        cfg.get("custom_fields", {}),
        pk_to_pass,
        team_uuid,
    )

    # ==========================================
    # 5. NETWORK EXECUTION: UPSERT
    # ==========================================
    target_key = None

    if is_dry_run:
        print(
            f"\n{C['bg_gray']}{C['bold']}{C['cyan']} 🚧 DRY RUN: PRIMARY UPSERT PAYLOAD 🚧 {C['reset']}\n"
        )
        print(json.dumps(upsert_payload, indent=2))
        target_key = issue_key.upper() if issue_key else "DRYRUN-999"
    else:
        if issue_key:
            success = update_issue(
                server,
                token,
                f"issue/{issue_key.upper()}",
                upsert_payload,
                method="PUT",
            )
            if success:
                notify_user(f"Successfully updated {issue_key}", "Jira Edit", use_toast)
                target_key = issue_key.upper()
            else:
                notify_user(f"Failed to update {issue_key}", "Jira Error", use_toast)
                sys.exit(1)
        else:
            response = update_issue(
                server, token, "issue", upsert_payload, method="POST"
            )
            if response and isinstance(response, dict) and "key" in response:
                target_key = response["key"]
                notify_user(
                    f"Successfully created {target_key}", "Jira Create", use_toast
                )
            else:
                notify_user("Failed to create issue", "Jira Error", use_toast)
                sys.exit(1)

    # ==========================================
    # 6. NETWORK EXECUTION: SPRINT ASSIGNMENT
    # ==========================================
    if frontmatter_dict.get("sprint"):
        board_id = board_cfg.get("id")
        if is_dry_run:
            print(
                f"\n{C['bg_gray']}{C['bold']}{C['blue']} 🏃 DRY RUN: SPRINT ADDITION 🏃 {C['reset']}\n"
            )
            print(f"{C['dim']}Target Issue:{C['reset']} {target_key}")
            print(f"{C['dim']}Board ID:{C['reset']} {board_id}")
        else:
            sprint_id = fetch_active_sprint(server, token, board_id)
            if sprint_id:
                s_success = add_to_sprint(server, token, sprint_id, target_key)
                if s_success:
                    notify_user(
                        f"Added {target_key} to active sprint.",
                        "Sprint Update",
                        use_toast,
                    )
                else:
                    notify_user(
                        f"Failed to add {target_key} to sprint.",
                        "Sprint Error",
                        use_toast,
                    )
            else:
                notify_user(
                    "No active sprint found for board.", "Sprint Warning", use_toast
                )

    # ==========================================
    # 7. NETWORK EXECUTION: TRANSITION
    # ==========================================
    new_status = frontmatter_dict.get("status")

    if (
        new_status
        and target_key
        and new_status.lower() != (current_status or "").lower()
    ):
        if not is_edit and new_status.lower() == "backlog":
            pass
        else:
            transitions = (
                fetch_transitions(server, token, target_key)
                if target_key != "DRYRUN-999"
                else [{"id": "99", "name": new_status}]
            )

            target_transition_id = None
            for t in transitions:
                if (
                    t.get("name", "").lower() == new_status.lower()
                    or t.get("to", {}).get("name", "").lower() == new_status.lower()
                ):
                    target_transition_id = t["id"]
                    break

            if target_transition_id:
                t_payload = build_transition_payload(target_transition_id)
                if is_dry_run:
                    print(
                        f"\n{C['bg_gray']}{C['bold']}{C['magenta']} 🚀 DRY RUN: STATUS TRANSITION 🚀 {C['reset']}\n"
                    )
                    print(json.dumps(t_payload, indent=2))
                else:
                    t_success = update_issue(
                        server,
                        token,
                        f"issue/{target_key}/transitions",
                        t_payload,
                        method="POST",
                    )
                    if t_success:
                        notify_user(
                            f"Moved {target_key} to {new_status}",
                            "Jira Upsert",
                            use_toast,
                        )
                    else:
                        notify_user(
                            f"Failed to move {target_key} to {new_status}",
                            "Jira Error",
                            use_toast,
                        )
            else:
                msg = f"Invalid status transition: '{new_status}'"
                print(
                    f"\n{C['red']}{C['bold']} ⚠ WARNING: {msg} {C['reset']}"
                ) if is_dry_run else notify_user(msg, "Jira Warning", use_toast)

    if is_dry_run:
        input(f"\n{C['bold']}Dry run complete. Press Enter to return...{C['reset']}")
