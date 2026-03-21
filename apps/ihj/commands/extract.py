import os
import json
import glob
import sys
from tui.terminal import notify_user, copy_to_clipboard, prompt_numeric_menu
from tui.editor import open_in_editor
from jira.markdown import adf_to_markdown
from constants import C


def execute_extract(issue_key, cache_dir, cfg, use_toast):
    if not issue_key:
        return

    project_prefix = issue_key.split("-")[0].upper()
    board_slug = next(
        (
            slug
            for slug, b in cfg.get("boards", {}).items()
            if b.get("project_key", "").upper() == project_prefix
        ),
        None,
    )
    if not board_slug:
        notify_user(f"Could not map {issue_key} to a known board.", "Error", use_toast)
        sys.exit(1)

    files_to_check = glob.glob(os.path.join(cache_dir, f"{board_slug}_*.json"))
    all_issues = []
    for f in files_to_check:
        if f.endswith("_previews.json"):
            continue

        with open(f, "r") as fh:
            data = json.load(fh)
            if isinstance(data, list):
                all_issues.extend(data)

    issues_map = {i["key"]: i for i in all_issues if isinstance(i, dict)}

    if issue_key not in issues_map:
        notify_user(f"Issue {issue_key} not found in local cache.", "Error", use_toast)
        sys.exit(1)

    target = issues_map[issue_key]
    parent_key = target.get("fields", {}).get("parent", {}).get("key")

    options = [
        "Target Issue Only",
        "Target + Children",
    ]

    if parent_key:
        options.append("Target + Parent")
        options.append("Target + Parent + Children + Siblings (Full Family)")

    choice_idx = prompt_numeric_menu(
        options, f"LLM EXTRACT: {issue_key}", color=C["magenta"]
    )
    if choice_idx is None:
        sys.exit(0)

    selected_option = options[choice_idx]

    collected_keys = {issue_key}

    if "Children" in selected_option:
        for k, v in issues_map.items():
            if v.get("fields", {}).get("parent", {}).get("key") == issue_key:
                collected_keys.add(k)

    if "Parent" in selected_option and parent_key:
        collected_keys.add(parent_key)

    if "Siblings" in selected_option and parent_key:
        for k, v in issues_map.items():
            if v.get("fields", {}).get("parent", {}).get("key") == parent_key:
                collected_keys.add(k)

    editor_cmd = cfg.get("editor", "vim")
    delimiter = "_END_OF_PROMPT_"
    boilerplate = f"\n\n{delimiter}\nType your LLM prompt above. XML context will append automatically.\n"

    raw_prompt = open_in_editor(
        editor_cmd, boilerplate, prefix="llm_prompt_", target_line=1
    )

    user_prompt = raw_prompt.split(delimiter)[0].strip()

    if not user_prompt:
        notify_user("Extraction aborted (Empty prompt).", "Aborted", use_toast)
        sys.exit(0)

    xml_parts = [
        "<context>",
        "  <instruction>",
        f"    {user_prompt}",
        "  </instruction>",
    ]

    if len(collected_keys) == 1:
        xml_parts.extend(
            [
                "  <output_format>",
                "    Output your response as a single ihj-compatible Markdown block with YAML frontmatter.",
                "    You MUST wrap the entire response in markdown code backticks (```markdown).",
                "    Example:",
                "    ```markdown",
                "    ---",
                '    summary: "The issue title"',
                '    type: "Task"',
                f'    parent: "{issue_key}"',
                "    ---",
                "    Your detailed markdown description goes here...",
                "    ```",
                "  </output_format>",
            ]
        )
    else:
        from config.schema import generate_hierarchy_schema

        board_cfg = cfg.get("boards", {}).get(board_slug, {})
        hierarchy_schema = generate_hierarchy_schema(board_cfg)
        schema_json = json.dumps(hierarchy_schema, indent=2)

        xml_parts.extend(
            [
                "  <output_format>",
                "    Output your response as a structured, pretty printed YAML document.",
                "    You MUST wrap the output in 4 markdown code backticks (````yaml).",
                "    The YAML MUST strictly validate against the following JSON Schema:",
                "    <json_schema>",
                schema_json,
                "    </json_schema>",
                "  </output_format>",
            ]
        )

    xml_parts.append("  <issues>")

    types_included = set()

    for k in collected_keys:
        if k not in issues_map:
            continue
        iss = issues_map[k]
        f = iss.get("fields", {})
        itype = f.get("issuetype", {}).get("name", "Unknown")
        types_included.add(itype)
        summ = f.get("summary", "")
        status = f.get("status", {}).get("name", "")
        desc = adf_to_markdown(f.get("description")).strip()

        xml_parts.append(f'    <issue key="{k}" type="{itype}" status="{status}">')
        xml_parts.append(f"      <summary>{summ}</summary>")
        if desc:
            xml_parts.append(f"      <description>\n{desc}\n      </description>")
        xml_parts.append("    </issue>")

    xml_parts.append("  </issues>")

    board_types = cfg.get("boards", {}).get(board_slug, {}).get("types", [])
    templates_added = False

    for t in board_types:
        if t["name"] in types_included and t.get("template"):
            if not templates_added:
                xml_parts.append("  <templates>")
                templates_added = True
            xml_parts.append(
                f'    <template type="{t["name"]}">\n{t["template"].strip()}\n    </template>'
            )

    if templates_added:
        xml_parts.append("  </templates>")

    xml_parts.append("</context>")

    final_xml = "\n".join(xml_parts)
    copy_to_clipboard(final_xml)
    notify_user(
        f"Copied XML context ({len(collected_keys)} issues) to clipboard!",
        "LLM Ready",
        use_toast,
    )
