import argparse
import sys
from config.formatters import clean_issue_key, strip_ansi
from constants import C


class IHJParser(argparse.ArgumentParser):
    """Custom parser that prints full contextual help on error."""

    def error(self, message):
        sys.stderr.write(f"\n{C['red']}{C['bold']}Error:{C['reset']} {message}\n\n")
        self.print_help()
        sys.exit(2)


def parse_args():
    """Builds the schema and returns the parsed, sanitized arguments."""
    global_parser = IHJParser(add_help=False)
    global_parser.add_argument(
        "--dry-run", action="store_true", help="Print payloads without mutating Jira"
    )

    parser = IHJParser(
        prog="ihj",
        description="The Instant High-speed Jira CLI",
        epilog="Run 'ihj <command> -h' for contextual help.",
        parents=[global_parser],
    )

    subparsers = parser.add_subparsers(dest="command", parser_class=IHJParser)

    # --- 1. CORE VIEWS ---
    tui_p = subparsers.add_parser(
        "tui", parents=[global_parser], help="Launch the interactive FZF UI (Default)"
    )
    tui_p.add_argument("board", nargs="?", help="Target board slug")
    tui_p.add_argument("filter", nargs="?", help="Target filter")

    list_p = subparsers.add_parser(
        "list", parents=[global_parser], help="Print issues to stdout"
    )
    list_p.add_argument("board", nargs="?", help="Target board slug")
    list_p.add_argument("filter", nargs="?", help="Target filter")

    export_p = subparsers.add_parser(
        "export", parents=[global_parser], help="Export issue hierarchy as JSON"
    )
    export_p.add_argument("board", nargs="?", help="Target board slug")
    export_p.add_argument("filter", nargs="?", help="Target filter")

    bootstrap_p = subparsers.add_parser(
        "bootstrap", parents=[global_parser], help="Scaffold a board config from Jira"
    )
    bootstrap_p.add_argument(
        "project_key", help="The Jira Project Key (e.g., INFRA, CIAM)"
    )

    # --- 2. UPSERT ---
    create_p = subparsers.add_parser(
        "create", parents=[global_parser], help="Create a new Jira issue"
    )
    create_p.add_argument("-b", "--board", help="Target board slug")
    create_p.add_argument("-s", "--summary", help="Issue summary")
    create_p.add_argument("-t", "--type", help="Issue type (e.g., Story)")
    create_p.add_argument("-p", "--priority", help="Priority (e.g., High)")
    create_p.add_argument("-S", "--status", help="Initial status")
    create_p.add_argument("-T", "--team", help="Team assignment value")
    create_p.add_argument(
        "-P", "--parent", type=clean_issue_key, help="Parent issue key"
    )

    edit_p = subparsers.add_parser(
        "edit", parents=[global_parser], help="Edit an existing Jira issue"
    )
    edit_p.add_argument(
        "issue_key", type=clean_issue_key, help="The issue key (e.g., CIAM-123)"
    )
    edit_p.add_argument("-b", "--board", help="Target board slug")
    edit_p.add_argument("-s", "--summary", help="Update summary")
    edit_p.add_argument("-t", "--type", help="Update type")
    edit_p.add_argument("-p", "--priority", help="Update priority")
    edit_p.add_argument("-S", "--status", help="Update status")
    edit_p.add_argument("-T", "--team", help="Update team assignment")
    edit_p.add_argument(
        "-P", "--parent", type=clean_issue_key, help="Update parent issue key"
    )

    # --- 3. QUICK ACTIONS ---
    branch_p = subparsers.add_parser(
        "branch", parents=[global_parser], help="Generate a git branch name"
    )
    branch_p.add_argument("issue_key", type=clean_issue_key, help="The issue key")
    branch_p.add_argument(
        "-b", "--board", help="Optional: restrict cache search to this board"
    )

    assign_p = subparsers.add_parser(
        "assign", parents=[global_parser], help="Assign an issue to yourself"
    )
    assign_p.add_argument("issue_key", type=clean_issue_key, help="The issue key")

    comment_p = subparsers.add_parser(
        "comment", parents=[global_parser], help="Add a comment to an issue"
    )
    comment_p.add_argument("issue_key", type=clean_issue_key, help="The issue key")

    trans_p = subparsers.add_parser(
        "transition", parents=[global_parser], help="Change issue status"
    )
    trans_p.add_argument("issue_key", type=clean_issue_key, help="The issue key")

    open_p = subparsers.add_parser(
        "open", parents=[global_parser], help="Open an issue in the browser"
    )
    open_p.add_argument("issue_key", type=clean_issue_key, help="The issue key")

    filter_p = subparsers.add_parser(
        "filter", parents=[global_parser], help="Switch the active board filter"
    )
    filter_p.add_argument("board", help="Target board slug")

    extract_p = subparsers.add_parser(
        "extract", parents=[global_parser], help="Extract issue and relations for an LLM prompt"
    )
    extract_p.add_argument("issue_key", type=clean_issue_key, help="The issue key")

    clean_argv = [strip_ansi(arg) for arg in sys.argv[1:]]
    return parser.parse_args(clean_argv)
