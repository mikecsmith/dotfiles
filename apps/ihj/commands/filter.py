import sys
from tui.terminal import prompt_numeric_menu
from constants import C


def execute_filter(board_slug, cfg):
    if not board_slug:
        return

    board_cfg = cfg.get("boards", {}).get(board_slug)
    if not board_cfg:
        return

    filters = list(board_cfg.get("filters", {}).keys())

    if not filters:
        sys.exit(1)

    choice_idx = prompt_numeric_menu(
        filters, f"󰡃 SELECT FILTER FOR {board_slug.upper()}", color=C["cyan"]
    )

    if choice_idx is not None:
        selected_filter = filters[choice_idx]
        with open("/tmp/j_mode", "w") as f:
            f.write(selected_filter)
