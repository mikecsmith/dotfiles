validate_param() {
  local value="$1"
  if [[ -n "$value" && "$value" != "null" ]]; then
    return 0
  else
    return 1
  fi
}
