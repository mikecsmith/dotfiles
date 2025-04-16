append_template() {
  local type="$1"
  local file="$2"

  case "$type" in
  "Epic") cat "$J_CONFIG_DIR/templates/epic.md" >>"$file" ;;
  "Story") cat "$J_CONFIG_DIR/templates/story.md" >>"$file" ;;
  "Task") cat "$J_CONFIG_DIR/templates/task.md" >>"$file" ;;
  "Bug") cat "$J_CONFIG_DIR/templates/bug.md" >>"$file" ;;
  esac
}
