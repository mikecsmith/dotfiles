import os
import sys

from config.schema import generate_frontmatter_schema, build_frontmatter_doc
from config.io import write_frontmatter_schema_file, parse_yaml_string
from tui.terminal import notify_user, prompt_numeric_menu
from tui.editor import open_in_editor, calculate_cursor_target
from tui.dry_run import print_dry_run
from jira.markdown import adf_to_markdown, split_frontmatter_and_body, markdown_to_adf
from jira.payloads import (
    build_search_payload,
    parse_search_response,
    build_upsert_payload,
    build_transition_payload,
)
from jira.workflows import get_transition_id, perform_transition, assign_to_sprint
from constants import C


def execute_upsert(args, cache_dir, client, cfg, use_toast, is_edit=False):
    editor_cmd = cfg.get("editor") or os.environ.get("EDITOR", "vim")
    is_dry_run = getattr(args, "dry_run", False)

    board_slug = getattr(args, "board", None) or cfg.get("default_board", "ci")
    board_cfg = cfg.get("boards", {}).get(board_slug, {})

    schema_dict = generate_frontmatter_schema(cfg, board_cfg)
    schema_path = write_frontmatter_schema_file(cache_dir, board_slug, schema_dict)

    metadata = {}
    body_text = ""
    orig_status = ""
    issue_key = None

    # --- 1. DATA GATHERING (Fetch vs Template) ---
    if is_edit:
        issue_key_raw = getattr(args, "issue_key", None)
        if not issue_key_raw:
            notify_user("Issue key is required for edit.", "Error", use_toast)
            sys.exit(1)
        issue_key = str(issue_key_raw)

        payload = build_search_payload(
            f"key = {issue_key}", cfg.get("formatted_custom_fields", {})
        )
        raw_response = client.search_issues(payload)
        issues, _, _ = parse_search_response(raw_response)

        if not issues:
            notify_user(f"Issue {issue_key} not found.", "Error", use_toast)
            sys.exit(1)

        fields = issues[0].get("fields", {})
        orig_status = fields.get("status", {}).get("name", "")

        metadata = {
            "key": issue_key,
            "type": getattr(args, "type", None)
            or fields.get("issuetype", {}).get("name", ""),
            "priority": getattr(args, "priority", None)
            or fields.get("priority", {}).get("name", "Medium"),
            "status": getattr(args, "status", None) or orig_status,
            "parent": getattr(args, "parent", None)
            or fields.get("parent", {}).get("key", ""),
            "summary": getattr(args, "summary", None) or fields.get("summary", ""),
        }

        for cf_name, cf_id in cfg.get("custom_fields", {}).items():
            if cf_name == "team":
                metadata["team"] = getattr(args, "team", None) or "true"
            else:
                val = fields.get(f"customfield_{cf_id}")
                if val:
                    val_str = (
                        val.get("value") or val.get("name")
                        if isinstance(val, dict)
                        else val
                    )
                    metadata[cf_name] = val_str

        body_text = adf_to_markdown(fields.get("description")).strip()

    else:
        types = [t["name"] for t in cfg.get("types", [])]
        selected_type = getattr(args, "type", None)
        if not selected_type:
            choice_idx = prompt_numeric_menu(
                types, "CREATE NEW ISSUE", color=C["green"]
            )
            if choice_idx is None:
                sys.exit(0)
            selected_type = types[choice_idx]

        type_cfg = next(
            (t for t in cfg.get("types", []) if t["name"] == selected_type), {}
        )
        orig_status = "Backlog"

        metadata = {
            "type": selected_type,
            "priority": getattr(args, "priority", None) or "Medium",
            "status": getattr(args, "status", None) or orig_status,
            "parent": getattr(args, "parent", None),
            "summary": getattr(args, "summary", None) or "",
        }

        if "team" in cfg.get("custom_fields", {}):
            metadata["team"] = getattr(args, "team", None) or "true"

        body_text = type_cfg.get("template", "").strip()

    # --- 2. EDITOR LIFECYCLE ---
    initial_doc = build_frontmatter_doc(schema_path, metadata, body_text)

    target_line, search_pattern = calculate_cursor_target(
        initial_doc, metadata.get("summary")
    )
    raw_modified = open_in_editor(
        editor_cmd, initial_doc, target_line=target_line, search_pattern=search_pattern
    )

    if raw_modified.strip() == initial_doc.strip():
        if is_dry_run:
            print_dry_run("ABORTED", message="No changes detected.")
        else:
            notify_user("No changes made.", "Skipped", use_toast)
        sys.exit(0)

    # --- 3. PARSING & VALIDATION ---
    yaml_str, md_body = split_frontmatter_and_body(raw_modified)
    fm = parse_yaml_string(yaml_str)

    if not fm or not fm.get("summary"):
        notify_user("Aborted: Summary is required.", "Error", use_toast)
        sys.exit(1)

    adf_body = markdown_to_adf(md_body)

    # --- 4. EXECUTE UPSERT (PUT vs POST) ---
    upsert_payload = build_upsert_payload(
        fm,
        adf_body,
        cfg["types"],
        cfg["custom_fields"],
        project_key=board_cfg.get("project_key"),
        team_uuid=board_cfg.get("team_uuid"),
    )

    target_key = issue_key
    if is_dry_run:
        target_key = target_key or "DRYRUN-999"
        print_dry_run(f"UPSERT PAYLOAD ({target_key})", data=upsert_payload)
    else:
        if is_edit:
            if not client.put(f"/rest/api/3/issue/{issue_key}", upsert_payload):
                notify_user(f"Failed to update {issue_key}", "Error", use_toast)
                sys.exit(1)
            notify_user(f"Successfully updated {issue_key}", "Jira Edit", use_toast)
        else:
            response = client.post("/rest/api/3/issue", upsert_payload)
            if response and isinstance(response, dict) and "key" in response:
                target_key = str(response["key"])
                notify_user(
                    f"Successfully created {target_key}", "Jira Create", use_toast
                )
            else:
                notify_user("Failed to create issue", "Error", use_toast)
                sys.exit(1)

    # --- 5. POST-UPSERT ACTIONS ---
    if fm.get("sprint"):
        if is_dry_run:
            print_dry_run(
                "SPRINT ADDITION",
                message=f"Target: {target_key} | Board ID: {board_cfg.get('id')}",
            )
        else:
            success, sprint_id = assign_to_sprint(
                client, board_cfg.get("id"), target_key
            )
            if success:
                notify_user(
                    f"Added {target_key} to active sprint.", "Sprint Update", use_toast
                )
            elif sprint_id is None:
                notify_user(
                    "No active sprint found for board.", "Sprint Warning", use_toast
                )
            else:
                notify_user(
                    f"Failed to add {target_key} to sprint.", "Sprint Error", use_toast
                )

    new_status = fm.get("status")
    if new_status and new_status.lower() != orig_status.lower():
        tid = get_transition_id(client, target_key, new_status)

        if is_dry_run:
            if tid:
                print_dry_run(
                    "STATUS TRANSITION",
                    data=build_transition_payload(tid),
                    message=f"Path: {orig_status} -> {new_status} (ID: {tid})",
                )
            else:
                print_dry_run(
                    "INVALID TRANSITION",
                    message=f"'{new_status}' is not a valid transition path.",
                )
        else:
            if tid:
                if perform_transition(client, target_key, tid):
                    notify_user(f"Moved to {new_status}", str(target_key), use_toast)
                else:
                    notify_user(
                        f"Failed to move {target_key} to {new_status}",
                        "Error",
                        use_toast,
                    )
            else:
                notify_user(
                    f"Invalid status transition: '{new_status}'", "Warning", use_toast
                )

    if is_dry_run:
        input(f"\n{C['bold']}Press Enter to finish dry run...{C['reset']}")
