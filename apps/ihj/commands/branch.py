import os
import json
import re
from tui.formatters import clean_issue_key
from tui.terminal import notify_user, copy_to_clipboard


def execute_branch(args, cache_dir, use_toast):
    # args: [slug, mode, key]
    if len(args) < 3:
        return

    slug, mode, raw_key = args[-3], args[-2], args[-1]
    clean_key = clean_issue_key(raw_key)
    cache_file = os.path.join(cache_dir, f"{slug}_{mode}.json")

    if not os.path.exists(cache_file):
        notify_user("Cache missing", "Branch Error", use_toast)
        return

    with open(cache_file, "r") as f:
        issues = json.load(f)

    # Search in main issues or parents
    summary = next(
        (
            i.get("fields", {}).get("summary")
            for i in issues
            if i.get("key") == clean_key
        ),
        None,
    )
    if not summary:
        summary = next(
            (
                i.get("fields", {}).get("parent", {}).get("fields", {}).get("summary")
                for i in issues
                if i.get("fields", {}).get("parent", {}).get("key") == clean_key
            ),
            None,
        )

    if summary:
        clean_summ = re.sub(r"[^a-z0-9]+", "-", summary.lower()).strip("-")
        branch_cmd = f"git checkout -b {clean_key.lower()}-{clean_summ}"
        copy_to_clipboard(branch_cmd)
        notify_user(branch_cmd, "Branch Copied!", use_toast)
    else:
        notify_user(f"Could not find {clean_key} in cache.", "Branch Error", use_toast)
