import os
import json
import time
from jira.jql_builder import build_jql
from jira.payloads import build_search_payload, parse_search_response
from jira.client import search_jira
from tui.view_builders import build_issue_registry, build_fzf_preview
from tui.terminal import get_terminal_width, launch_fzf
from constants import C


def get_board_data(cache_dir, server, token, board_cfg, mode, custom_fields):
    slug = board_cfg.get("slug")
    cache_file = os.path.join(cache_dir, f"{slug}_{mode}.json")

    if os.path.exists(cache_file):
        age = int(time.time() - os.path.getmtime(cache_file))
        if age < 900:  # 15 min cache
            with open(cache_file, "r") as f:
                return json.load(f), age

    jql = build_jql(board_cfg, mode, custom_fields)
    all_issues = []
    next_token = None
    while True:
        payload = build_search_payload(jql, custom_fields, next_token)
        raw_response = search_jira(server, token, payload)
        issues, next_token, is_last = parse_search_response(raw_response)
        all_issues.extend(issues)
        if is_last:
            break

    with open(cache_file, "w") as f:
        json.dump(all_issues, f)
    return all_issues, 0


def execute_list(args, cache_dir, executable, server, token, cfg):
    is_list = "--list" in args
    clean_args = [a for a in args if a not in ["--list", "--toast"]]

    slug = clean_args[0] if len(clean_args) > 0 else cfg.get("default_board", "ci")
    mode = clean_args[1] if len(clean_args) > 1 else "active"

    board_cfg = cfg["boards"].get(slug)
    board_cfg["slug"] = slug

    # Track current mode for FZF reloads
    with open("/tmp/j_mode", "w") as f:
        f.write(mode)

    raw_issues, age = get_board_data(
        cache_dir, server, token, board_cfg, mode, cfg["formatted_custom_fields"]
    )

    term_w = get_terminal_width()
    registry = build_issue_registry(raw_issues, term_w)
    lines, previews = build_fzf_preview(registry, cfg["type_order_map"], term_w)

    preview_path = os.path.join(cache_dir, f"{slug}_previews.json")
    with open(preview_path, "w") as f:
        json.dump(previews, f)

    if is_list:
        header = f"{C['bold']}{'ID':<12} P {'TYPE':<10} {'STATUS':<16} {'ASSIGNEE':<16} SUMMARY{C['reset']}"
        print(header + "\n" + "\n".join(lines))
        return

    bindings = {
        "alt-r": f"reload(rm -f {cache_dir}/{slug}_*.json && {executable} --list {slug} $(cat /tmp/j_mode))",
        "alt-s": f"execute({executable} --choose-mode {slug})+reload({executable} --list {slug} $(cat /tmp/j_mode))",
        "alt-a": f"execute-silent({executable} --assign {{1}} --toast)+reload(rm -f {cache_dir}/{slug}_*.json && {executable} --list {slug} $(cat /tmp/j_mode))",
        "alt-t": f"execute({executable} --transition {slug} {{1}})+reload(rm -f {cache_dir}/{slug}_*.json && {executable} --list {slug} $(cat /tmp/j_mode))",
        "alt-o": f"execute-silent({executable} --open {{1}})",
        "alt-e": f"execute({executable} --edit -b {slug} {{1}} --toast)+reload(rm -f {cache_dir}/{slug}_*.json && {executable} --list {slug} $(cat /tmp/j_mode))",
        "alt-c": f"execute({executable} --comment {{1}} --toast)+reload(rm -f {cache_dir}/{slug}_*.json && {executable} --list {slug} $(cat /tmp/j_mode))",
        "alt-n": f"execute-silent({executable} --branch {slug} $(cat /tmp/j_mode) {{1}} --toast)",
        "ctrl-n": f"execute({executable} --create -b {slug} --toast)+reload(rm -f {cache_dir}/{slug}_*.json && {executable} --list {slug} $(cat /tmp/j_mode))",
    }

    launch_fzf(lines, board_cfg.get("name", slug), mode, age, preview_path, bindings)
