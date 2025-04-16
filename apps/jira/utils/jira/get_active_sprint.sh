get_active_sprint() {
  local force="$1"
  local cache_file="/tmp/active_sprint_cache.json"
  local api_url=$JIRA_ACTIVE_SPRINT_URL

  if [[ "$force" != "force" ]]; then
    if [[ -f "$cache_file" ]]; then
      local cached_end_date
      cached_end_date=$(jq -r '.endDate' "$cache_file")

      if [[ "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" < "$cached_end_date" ]]; then
        echo "Using cached active sprint:"
        cat "$cache_file"
        return
      fi
    fi
  fi

  local response
  response=$(curl -s -X GET "$api_url" \
    -H "Accept: application/json" \
    -H "Authorization: Basic $JIRA_BEARER_TOKEN")

  local active_sprint
  active_sprint=$(echo "$response" | jq '.values[0]')

  echo "$active_sprint" >"$cache_file"

  echo "$active_sprint" | jq -r '.id'
}
