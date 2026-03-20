import os
import json
import time
from jira.client import fetch_myself_api, update_issue
from jira.payloads import build_assignment_payload
from tui.formatters import clean_issue_key
from tui.terminal import notify_user


def get_my_account_id(cache_dir, server, token):
    cache_file = os.path.join(cache_dir, "myself.json")
    if (
        os.path.exists(cache_file)
        and (time.time() - os.path.getmtime(cache_file)) < 604800
    ):
        with open(cache_file, "r") as f:
            return json.load(f).get("accountId")

    data = fetch_myself_api(server, token)
    if data and "accountId" in data:
        with open(cache_file, "w") as f:
            json.dump(data, f)
        return data["accountId"]
    return None


def execute_assign(args, cache_dir, server, token, use_toast):
    clean_key = clean_issue_key(args[-1])
    account_id = get_my_account_id(cache_dir, server, token)

    if not account_id:
        notify_user("Could not fetch Account ID", "Jira Error", use_toast)
        return

    payload = build_assignment_payload(account_id)
    success = update_issue(
        server, token, f"issue/{clean_key}/assignee", payload, method="PUT"
    )

    if success:
        notify_user(f"Assigned {clean_key} to you.", "Jira Updated", use_toast)
    else:
        notify_user(f"Failed to assign {clean_key}.", "Jira Error", use_toast)
