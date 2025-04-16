get_filter() {
  local any_flag="$1"

  if [[ "$any_flag" == "1" ]]; then
    local assignees
    read -r -a assignees <<<"${JIRA_TEAM_MEMBERS//,/ }"

    local assignee_filter
    assignee_filter=$(printf ',"%s"' "${assignees[@]}")
    assignee_filter=${assignee_filter:1} # Remove leading comma
    echo "assignee IN ($assignee_filter)"
  else
    echo "assignee = \"$(jira me)\""
  fi
}
