import os
import sys
import json

from tui.terminal import notify_user, open_in_editor
from jira.client import update_issue

from tui.formatters import clean_issue_key
from jira.markdown import markdown_to_adf
from jira.payloads import build_comment_payload
from constants import C


def execute_comment(args, server, token, cfg):
    """The comment subcommand allows you to create a new comment on an issue."""
    editor_cmd = cfg.get("editor") or os.environ.get("EDITOR", "vim")
    is_dry_run = "--dry-run" in args
    use_toast = "--toast" in args

    clean_args = [a for a in args if not a.startswith("-")]
    if len(clean_args) < 2:
        notify_user("Issue key required for comment.", "Error", use_toast)
        sys.exit(1)

    issue_key = clean_issue_key(clean_args[-1])

    raw_comment = open_in_editor(
        editor_cmd, "", prefix=f"j_comment_{issue_key}_", target_line=1
    )

    final_comment = raw_comment.strip()

    if not final_comment:
        if is_dry_run:
            print(f"\n{C['dim']}Empty comment. Aborting.{C['reset']}")
        else:
            notify_user("Aborted: Comment is empty.", "Cancelled", use_toast)
        sys.exit(0)

    adf_body = markdown_to_adf(final_comment)
    payload = build_comment_payload(adf_body)

    if is_dry_run:
        print(
            f"\n{C['bg_gray']}{C['bold']}{C['cyan']} 🚧 DRY RUN: COMMENT PAYLOAD 🚧 {C['reset']}\n"
        )
        print(f"{C['dim']}Endpoint:{C['reset']} POST issue/{issue_key}/comment")
        print(json.dumps(payload, indent=2))
        input(f"\n{C['bold']}Dry run complete. Press Enter to return...{C['reset']}")
        sys.exit(0)

    success = update_issue(
        server, token, f"issue/{issue_key}/comment", payload, method="POST"
    )

    if success:
        notify_user(f"Added comment to {issue_key}", "Jira Comment", use_toast)
    else:
        notify_user(f"Failed to add comment to {issue_key}", "Jira Error", use_toast)
        sys.exit(1)
