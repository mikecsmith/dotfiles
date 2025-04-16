validate_with_schema() {
  local schema_file="$1"
  local input="$2"

  [[ "$J_DEBUG" = "1" ]] && echo "DEBUG: Starting validation..." >&2
  [[ "$J_DEBUG" = "1" ]] && echo "DEBUG: Schema file: $schema_file" >&2
  [[ "$J_DEBUG" = "1" ]] && echo "DEBUG: Input length: ${#input}" >&2

  local temp_data_file
  temp_data_file=$(mktemp "/tmp/jira_frontmatter.yml")
  [[ "$J_DEBUG" = "1" ]] && echo "DEBUG: Temp file created: $temp_data_file" >&2

  if [ ! -f "$temp_data_file" ]; then
    echo "Failed to create temporary file with mktemp: $temp_data_file" >&2
    return 1
  fi

  echo "$input" >"$temp_data_file"
  [[ "$J_DEBUG" = "1" ]] && echo "DEBUG: Wrote input to temp file" >&2

  [[ "$J_DEBUG" = "1" ]] && echo "DEBUG: File contents:" >&2
  [[ "$J_DEBUG" = "1" ]] && cat "$temp_data_file" >&2

  [[ "$J_DEBUG" = "1" ]] && echo "DEBUG: Running jsonschema..." >&2
  jsonschema validate "$schema_file" "$temp_data_file" >&2
  local result=$?
  [[ "$J_DEBUG" = "1" ]] && echo "DEBUG: jsonschema exit code: $result" >&2

  cat "$temp_data_file"
  rm -f "$temp_data_file"
  return $result
}
