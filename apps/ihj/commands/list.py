import os
import json
import sys
from constants import C
from commands.tui import get_board_data
from tui.view_builders import build_issue_registry, build_fzf_preview
from tui.terminal import get_terminal_width


def execute_list(slug, mode, cache_dir, client, cfg):
    """Outputs the formatted issue list to stdout (Used by FZF reload and CLI)."""
    board_cfg = cfg["boards"].get(slug)
    if not board_cfg:
        sys.exit(f"Error: Board '{slug}' not found in config.")
    board_cfg["slug"] = slug

    raw_issues, _ = get_board_data(
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

    header = f"{C['bold']}{'ID':<12} P {'TYPE':<10} {'STATUS':<16} {'ASSIGNEE':<16} SUMMARY{C['reset']}"
    print(header)
    for line in lines:
        print(line)
