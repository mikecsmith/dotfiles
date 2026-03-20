import os
import json
import time
from jira.payloads import build_assignment_payload
from tui.terminal import notify_user


def get_my_account_id(cache_dir, client):
    cache_file = os.path.join(cache_dir, "myself.json")
    if (
        os.path.exists(cache_file)
        and (time.time() - os.path.getmtime(cache_file)) < 604800
    ):
        with open(cache_file, "r") as f:
            return json.load(f).get("accountId")

    data = client.fetch_myself()
    if data and "accountId" in data:
        with open(cache_file, "w") as f:
            json.dump(data, f)
        return data["accountId"]
    return None


def execute_assign(issue_key, cache_dir, client, use_toast):
    if not issue_key:
        return

    account_id = get_my_account_id(cache_dir, client)

    if not account_id:
        notify_user("Could not fetch Account ID", "Jira Error", use_toast)
        return

    payload = build_assignment_payload(account_id)
    success = client.put(f"/rest/api/3/issue/{issue_key}/assignee", payload)

    if success:
        notify_user(f"Assigned {issue_key} to you.", "Jira Updated", use_toast)
    else:
        notify_user(f"Failed to assign {issue_key}.", "Jira Error", use_toast)
