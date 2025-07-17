pipe_to_fzf() {
  local fetch_command="jira issue view"

  local input
  input=$(cat)

  local me
  me=$(jira me)

  # Parse out the issue keys and pass to xargs to warm the bkt cache
  echo "$input" | awk 'NR > 1 {print $1}' | xargs -n1 -P4 -I{} bkt --ttl=15m --warm -- bash -c "$fetch_command \"{}\""

  echo "$input" | fzf \
    --ansi \
    --border \
    --padding 1,2 \
    --border-label ' Issues ' --input-label ' Search ' \
    --layout=reverse \
    --header-lines=1 \
    --preview-window=top:60%:wrap \
    --preview="bkt --ttl=15m --stale=1m -- bash -c \"$fetch_command {1}\" | glow --pager never -s dark" \
    --bind='alt-p:toggle-preview' \
    --bind='alt-b:preview-up' \
    --bind='alt-f:preview-down' \
    --bind="alt-a:execute(jira issue assign {1} $me)" \
    --bind='alt-e:execute(jira issue edit {1})' \
    --bind='alt-o:become(jira open {1})' \
    --bind='alt-u:become(jira open --no-browser {1} | pbcopy)' \
    --bind="alt-y:become[jira open --no-browser {1} | awk -F/ '{print \$NF}' | pbcopy ]" \
    --bind='alt-m:execute(jira issue move {1})' \
    --bind='alt-n:execute(echo {+} | awk -F"\t" '\''{issue=""; found=0; name=""; for(i=1;i<=NF;i++) { if(issue=="" && $i!="") issue=$i; else if(issue!="" && found==0 && $i!="") found=1; else if(issue!="" && found==1 && $i!="") {name=$i; break} } print issue "-" name}'\'' | tr "[:upper:]" "[:lower:]" | sed "s/ /-/g" | sed "s/[^a-z0-9-]//g" | xargs -I{} echo "git checkout -b {}" | pbcopy)' \
    --bind='alt-c:execute(nvim /tmp/jira_comment.md -c "set ft=markdown" && jira issue comment add {1} < /tmp/jira_comment.md && rm /tmp/jira_comment.md)'
}
