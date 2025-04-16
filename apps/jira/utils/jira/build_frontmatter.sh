build_frontmatter() {
  local params=("$@")
  local frontmatter="---"

  for param in "${params[@]}"; do
    if [[ -z "$param" ]]; then
      continue
    fi

    frontmatter+="
$param"
  done

  frontmatter+="
---"
  echo -e "$frontmatter"
}
