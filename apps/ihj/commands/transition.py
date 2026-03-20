import sys
from tui.terminal import prompt_numeric_menu, notify_user
from jira.payloads import filter_transitions
from jira.workflows import perform_transition


def execute_transition(issue_key, client, cfg, use_toast):
    if not issue_key:
        return

    # Find the board this issue belongs to by looking at the prefix
    project_prefix = issue_key.split("-")[0].upper()
    board_slug = next(
        (
            slug
            for slug, b in cfg.get("boards", {}).items()
            if b.get("project_key", "").upper() == project_prefix
        ),
        None,
    )

    allowed_transitions = (
        cfg.get("boards", {}).get(board_slug, {}).get("transitions", [])
        if board_slug
        else []
    )

    raw_transitions = client.fetch_transitions(issue_key)
    filtered = filter_transitions(raw_transitions, allowed_transitions)
    names = [t["name"] for t in filtered]

    if not names:
        notify_user(f"No available transitions for {issue_key}", "Error", use_toast)
        sys.exit(1)

    choice_idx = prompt_numeric_menu(names, f"󰡃 TRANSITION: {issue_key}")
    if choice_idx is not None:
        tid = filtered[choice_idx]["id"]
        target_status = names[choice_idx]

        if perform_transition(client, issue_key, tid):
            notify_user(f"Moved to {target_status}", issue_key, use_toast=True)
        else:
            notify_user(f"Failed to move {issue_key}", "Error", use_toast=True)
