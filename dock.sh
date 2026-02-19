#!/usr/bin/env bash

# Configuration for the Dock
ENTRIES=(
  "/Applications/Google Chrome.app/|apps|"
  "/Applications/kitty.app/|apps|"
  "/Applications/Bruno.app/|apps|"
)

# Utility function to normalize app paths
normalize_path() {
  local path="$1"
  [[ "$path" == *.app ]] && echo "${path}/" || echo "$path"
}

# Function to create entry URIs
create_entry_uri() {
  local path
  path=$(normalize_path "$1")
  echo "file://${path}" | sed -e 's/ /%20/g' -e 's/!/%21/g' -e 's/\"/%22/g' -e 's/#/%23/g' -e 's/\$/%24/g' -e 's/%/%25/g' -e 's/&/%26/g' -e "s/'/%27/g" -e 's/(/%28/g' -e 's/)/%29/g'
}

# Main script logic
echo "Setting up the Dock..."

# Collect current URIs
have_uris=$(dockutil --list | cut -f2)
want_uris=""
for entry in "${ENTRIES[@]}"; do
  IFS='|' read -r path section options <<<"$entry"
  want_uris+=$(create_entry_uri "$path")$'\n'
done

# Compare and update dock entries if needed
if ! diff -wu <(echo -n "$have_uris") <(echo -n "$want_uris") >&2; then
  echo "Resetting Dock."
  dockutil --no-restart --remove all
  for entry in "${ENTRIES[@]}"; do
    IFS='|' read -r path section options <<<"$entry"
    echo "Adding $path to Dock..."
    dockutil --no-restart --add "$path" --section "$section" $options || {
      echo "Failed to add $path to Dock" >&2
      exit 1
    }
  done
  killall Dock
else
  echo "Dock setup complete."
fi
