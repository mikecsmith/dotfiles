import os
import json
import re
import glob
from tui.terminal import notify_user, copy_to_clipboard


def execute_branch(issue_key, board_slug, cache_dir, use_toast):
    if not issue_key:
        return

    files_to_check = []
    if board_slug:
        files_to_check.extend(
            glob.glob(os.path.join(cache_dir, f"{board_slug}_*.json"))
        )
    else:
        files_to_check.extend(glob.glob(os.path.join(cache_dir, "*_*.json")))

    summary = None
    for cache_file in files_to_check:
        if not os.path.exists(cache_file):
            continue

        with open(cache_file, "r") as f:
            issues = json.load(f)

        # Search in main issues or parents
        summary = next(
            (
                i.get("fields", {}).get("summary")
                for i in issues
                if i.get("key") == issue_key
            ),
            None,
        )
        if not summary:
            summary = next(
                (
                    i.get("fields", {})
                    .get("parent", {})
                    .get("fields", {})
                    .get("summary")
                    for i in issues
                    if i.get("fields", {}).get("parent", {}).get("key") == issue_key
                ),
                None,
            )

        if summary:
            break

    if summary:
        clean_summ = re.sub(r"[^a-z0-9]+", "-", summary.lower()).strip("-")
        branch_cmd = f"git checkout -b {issue_key.lower()}-{clean_summ}"
        copy_to_clipboard(branch_cmd)
        notify_user(branch_cmd, "Branch Copied!", use_toast)
    else:
        notify_user(f"Could not find {issue_key} in cache.", "Branch Error", use_toast)
