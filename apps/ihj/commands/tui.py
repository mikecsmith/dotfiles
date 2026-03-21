import os
import json
import time
import sys

from jira.jql_builder import build_jql
from jira.payloads import build_search_payload, parse_search_response
from tui.view_builders import build_issue_registry, build_fzf_preview
from tui.terminal import get_terminal_width, launch_fzf


def get_board_data(cache_dir, client, board_cfg, mode, custom_fields):
    """Fetches board data, utilizing the 15-minute local cache."""
    slug = board_cfg.get("slug")
    cache_file = os.path.join(cache_dir, f"{slug}_{mode}.json")

    if os.path.exists(cache_file):
        age = int(time.time() - os.path.getmtime(cache_file))
        if age < 900:
            with open(cache_file, "r") as f:
                return json.load(f), age

    jql = build_jql(board_cfg, mode, custom_fields)
    all_issues = []
    next_token = None

    while True:
        payload = build_search_payload(jql, custom_fields, next_token)
        raw_response = client.search_issues(payload)
        issues, next_token, is_last = parse_search_response(raw_response)
        all_issues.extend(issues)
        if is_last:
            break

    with open(cache_file, "w") as f:
        json.dump(all_issues, f)
    return all_issues, 0


def execute_tui(slug, mode, cache_dir, executable, client, cfg):
    """Launches the interactive FZF view."""
    board_cfg = cfg["boards"].get(slug)
    if not board_cfg:
        sys.exit(f"Error: Board '{slug}' not found in config.")
    board_cfg["slug"] = slug

    with open("/tmp/j_mode", "w") as f:
        f.write(mode)

    raw_issues, age = get_board_data(
        cache_dir, client, board_cfg, mode, cfg["formatted_custom_fields"]
    )

    term_w = get_terminal_width()
    registry = build_issue_registry(raw_issues, term_w)

    lines, previews = build_fzf_preview(
        registry, 
        board_cfg["type_order_map"], 
        term_w,
        transitions=board_cfg.get("transitions", [])
    )

    preview_path = os.path.join(cache_dir, f"{slug}_previews.json")
    with open(preview_path, "w") as f:
        json.dump(previews, f)

    reload_cmd = f"reload(rm -f {cache_dir}/{slug}_*.json && {executable} list {slug} $(cat /tmp/j_mode))"
    pause_on_err = "|| { echo '\nCommand failed. Press Enter to return to FZF...'; read -r < /dev/tty; }"

    bindings = {
        "alt-r": reload_cmd,
        "alt-f": f"execute({executable} filter {slug})+{reload_cmd}",
        "alt-a": f"execute-silent({executable} assign {{1}})+{reload_cmd}",
        "alt-t": f"execute({executable} transition {{1}} {pause_on_err})+{reload_cmd}",
        "alt-o": f"execute-silent({executable} open {{1}})",
        "alt-e": f"execute({executable} edit {{1}} -b {slug} {pause_on_err})+{reload_cmd}",
        "alt-c": f"execute({executable} comment {{1}} {pause_on_err})+{reload_cmd}",
        "alt-n": f"execute-silent({executable} branch {{1}} -b {slug})",
        "alt-x": f"execute({executable} extract {{1}} {pause_on_err})",
        "ctrl-n": f"execute({executable} create -b {slug} {pause_on_err})+{reload_cmd}",
    }

    launch_fzf(
        lines,
        board_cfg.get("name", slug),
        mode,
        age,
        preview_path,
        bindings,
    )
