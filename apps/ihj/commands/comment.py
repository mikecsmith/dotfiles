import os
import sys
from tui.terminal import notify_user
from tui.editor import open_in_editor
from tui.dry_run import print_dry_run
from jira.markdown import markdown_to_adf
from jira.payloads import build_comment_payload
from constants import C


def execute_comment(issue_key, client, cfg, use_toast, is_dry_run):
    """The comment subcommand allows you to create a new comment on an issue."""
    editor_cmd = cfg.get("editor") or os.environ.get("EDITOR", "vim")

    if not issue_key:
        notify_user("Issue key required for comment.", "Error", use_toast)
        sys.exit(1)

    raw_comment = open_in_editor(
        editor_cmd, "", prefix=f"j_comment_{issue_key}_", target_line=1
    )

    final_comment = raw_comment.strip()

    if not final_comment:
        if is_dry_run:
            print_dry_run("ABORTED", message="Empty comment.")
        else:
            notify_user("Aborted: Comment is empty.", "Cancelled", use_toast)
        sys.exit(0)

    adf_body = markdown_to_adf(final_comment)
    payload = build_comment_payload(adf_body)

    if is_dry_run:
        print_dry_run(
            "COMMENT PAYLOAD",
            data=payload,
            message=f"Endpoint: POST /rest/api/3/issue/{issue_key}/comment",
        )
        input(f"\n{C['bold']}Dry run complete. Press Enter to return...{C['reset']}")
        sys.exit(0)

    success = client.post(f"/rest/api/3/issue/{issue_key}/comment", payload)

    if success:
        notify_user(f"Added comment to {issue_key}", "Jira Comment", use_toast)
    else:
        notify_user(f"Failed to add comment to {issue_key}", "Jira Error", use_toast)
        sys.exit(1)
