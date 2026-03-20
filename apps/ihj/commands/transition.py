from jira.client import fetch_transitions, update_issue
from jira.payloads import build_transition_payload, filter_transitions
from tui.formatters import clean_issue_key
from tui.terminal import prompt_numeric_menu, notify_user


def execute_transition(args, server, token, cfg):
    # args: [slug, key]
    slug, raw_key = args[-2], args[-1]
    clean_key = clean_issue_key(raw_key)
    allowed = cfg.get("boards", {}).get(slug, {}).get("transitions", [])

    raw_transitions = fetch_transitions(server, token, clean_key)
    filtered = filter_transitions(raw_transitions, allowed)
    names = [t["name"] for t in filtered]

    choice_idx = prompt_numeric_menu(names, f"󰡃 TRANSITION: {clean_key}")
    if choice_idx is not None:
        payload = build_transition_payload(filtered[choice_idx]["id"])
        success = update_issue(server, token, f"issue/{clean_key}/transitions", payload)
        if success:
            notify_user(f"Moved to {names[choice_idx]}", clean_key, use_toast=True)
