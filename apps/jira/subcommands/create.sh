# @flag -s --sprint Add the issue to the active sprint
# @flag -b --bust Bust the cache
# @option --priority[=Medium|High|Low]
# @option --type[=Task|Epic|Bug|Story|Sub-task|Initiative] Specify the type of issue to create
# @option --parent Specify the parent issue
# @option --status[=Backlog|Refined|Refinement in progress|Refinement in review|Selected for Refinement|In Review|Ready for Development|Done|Wont do]

eval "$(argc --argc-eval "$0" "$@")"

# shellcheck source=../utils/jira/append_template.sh
source "$J_UTILS_DIR/jira/append_template.sh"
# shellcheck source=../utils/jira/validate_param.sh
source "$J_UTILS_DIR/jira/validate_param.sh"
# shellcheck source=../utils/jira/validate_with_schema.sh
source "$J_UTILS_DIR/jira/validate_with_schema.sh"
# shellcheck source=../utils/jira/build_frontmatter.sh
source "$J_UTILS_DIR/jira/build_frontmatter.sh"
# shellcheck source=../utils/jira/get_active_sprint.sh
source "$J_UTILS_DIR/jira/get_active_sprint.sh"

frontmatter_params=()

# shellcheck disable=SC2154,SC2046,SC2086
if [[ "$argc_type" == "Epic" ]]; then
  frontmatter_params+=("name: ")
fi

frontmatter_params+=(
  "summary: "
  "type: $argc_type"
  "status: $argc_status"
)

# shellcheck disable=SC2154,SC2046,SC2086
[[ "$argc_sprint" -eq 1 ]] && frontmatter_params+=("sprint: true")

if [[ -n "$argc_parent" ]]; then
  frontmatter_params+=("parent: $argc_parent")
fi

tmpfile=$(mktemp /tmp/jira_create_"$(date +%Y%m%d_%H%M%S)".md)

build_frontmatter "${frontmatter_params[@]}" >"$tmpfile"
append_template "$argc_type" "$tmpfile"

nvim +2 "$tmpfile"

yaml=$(awk '/^---/{flag=!flag; next} flag' "$tmpfile")

validated_yaml=$(validate_with_schema "$J_SCHEMAS_DIR/frontmatter.json" "$yaml")

body=$(awk 'BEGIN {found=0} /^---/ {found+=1; next} found==2 {print}' "$tmpfile")
name=$(echo "$validated_yaml" | yq -r '.name')
parent=$(echo "$validated_yaml" | yq -r '.parent')
priority=$(echo "$validated_yaml" | yq -r '.priority')
sprint=$(echo "$validated_yaml" | yq -r '.sprint')
status=$(echo "$validated_yaml" | yq -r '.status')
summary=$(echo "$validated_yaml" | yq -r '.summary')
type=$(echo "$validated_yaml" | yq -r '.type')

jira_params=()

if [[ "$type" == "Epic" ]]; then
  validate_param "$name" && jira_params+=("--name" "$name")
else
  validate_param "$type" && jira_params+=("--type" "$type")
  validate_param "$parent" && jira_params+=("--parent" "$parent")
fi

validate_param "$summary" && jira_params+=("--summary" "$summary")
validate_param "$priority" && jira_params+=("--priority" "$priority")

if [[ -n "$JIRA_TEAM" ]]; then
  jira_params+=("--custom" "team=$JIRA_TEAM")
fi

if [[ "$sprint" == "true" ]]; then
  # shellcheck disable=SC2154,SC2046,SC2086
  if [[ "$argc_bust" == "1" ]]; then
    sprint_id=$(get_active_sprint "force")
  else
    sprint_id=$(get_active_sprint)
  fi
  jira_params+=("--custom" "sprint=$sprint_id")
fi

jira_params+=("--raw")

echo "Creating $type in Jira... with ${jira_params[*]}"

if [[ "$type" == "Epic" ]]; then
  jira_output=$(echo "$body" | jira epic create "${jira_params[@]}" 2>&1)
else
  jira_output=$(echo "$body" | jira issue create "${jira_params[@]}" 2>&1)
fi

[[ "$J_DEBUG" = "1" ]] && echo "$jira_output"

if [[ "$jira_output" =~ \{.*\"key\":\"([^\"]+)\".*\} ]]; then
  issue_key="${BASH_REMATCH[1]}"
  echo "Created issue: $issue_key"
  echo "URL: $(jira open --no-browser "$issue_key")"
  if [[ -n "$status" && "$status" != "null" && "$status" != "Backlog" ]]; then
    echo "Transitioning $issue_key to status: $status"
    jira issue move "$issue_key" "$status" || {
      echo "Warning: Could not transition issue to '$status'. The issue was created successfully."
    }
  fi
fi
