from jira.client import search_jira
from jira.payloads import build_search_payload, parse_search_response
from jira.jql_builder import build_jql
from jira.hierarchy import build_export_hierarchy
from jira.persistence import save_export_state, write_export_output, build_metadata


def execute_export(args, server, token, cfg):
    """Handles the --export logic: Fetches, organizes, and writes to stdout."""
    # Find slug and mode from positional args
    slug = args[0] if len(args) > 0 else cfg.get("default_board", "ci")
    mode = args[1] if len(args) > 1 else "active"

    board_cfg = cfg["boards"].get(slug)
    if not board_cfg:
        return
    board_cfg["slug"] = slug

    # Always force a fresh fetch for exports to ensure data integrity
    jql = build_jql(board_cfg, mode, cfg["formatted_custom_fields"])

    all_issues = []
    next_token = None
    while True:
        payload = build_search_payload(jql, cfg["formatted_custom_fields"], next_token)
        raw_response = search_jira(server, token, payload)
        issues, next_token, is_last = parse_search_response(raw_response)
        all_issues.extend(issues)
        if is_last:
            break

    # Process hierarchy and save state for future syncs
    hierarchy, state_dict = build_export_hierarchy(all_issues)
    save_export_state(slug, state_dict)

    meta = build_metadata(slug, board_cfg)
    write_export_output({"metadata": meta, "issues": hierarchy})
