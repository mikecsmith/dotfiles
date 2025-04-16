# @describe Show Jira issues based on various filters
# @arg subcommand[=current|all|open|backlog|closed] The subcommand to execute (required).
# @flag -a --any Show issues from any user (removes -a$(jira me) filter)

eval "$(argc --argc-eval "$0" "$@")"

# shellcheck source=../utils/jira/get_filter.sh
source "$J_UTILS_DIR/jira/get_filter.sh"
# shellcheck source=../utils/fzf/pipe_to_fzf.sh
source "$J_UTILS_DIR/fzf/pipe_to_fzf.sh"

subcommand="$argc_subcommand"

filter=$(get_filter "${argc_args:-}")

case "$subcommand" in
all)
  jira issue list --jql "$filter" --plain --columns id,type,summary,status,reporter,assignee | pipe_to_fzf
  ;;
current)
  jira sprint list --table --current --plain --columns=id,type,summary,status,reporter,assignee | pipe_to_fzf
  ;;
open)
  jira issue list --jql "$filter AND status IN ('Ready for Development', 'In Progress', 'In Review')" --plain --columns id,type,summary,status,reporter,assignee | pipe_to_fzf
  ;;
backlog)
  jira issue list --jql "$filter AND status IN ('Backlog', 'Selected for Refinement', 'Refinement in progress', 'Refinement in review', 'Refined')" --plain --columns id,type,summary,status,reporter,assignee | pipe_to_fzf
  ;;
closed)
  jira issue list --jql "$filter AND status IN ('Done', 'Wont Do')" --plain --columns id,type,summary,status,reporter,assignee | pipe_to_fzf
  ;;
*)
  echo "Error: Unknown subcommand '$subcommand'" >&2
  exit 1
  ;;
esac
