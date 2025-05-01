get_active_sprint() {
  local api_url=$JIRA_ACTIVE_SPRINT_URL

  local response
  response=$(curl -s -X GET "$api_url" \
    -H "Accept: application/json" \
    -H "Authorization: Basic $JIRA_BEARER_TOKEN")

  local active_sprint
  active_sprint=$(echo "$response" | jq '.values[0]')

  echo "$active_sprint" | jq -r '.id'
}
