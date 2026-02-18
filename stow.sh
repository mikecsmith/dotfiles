#!/usr/bin/env bash

DOTFILES_DIR="$HOME/.dotfiles"
cd "$DOTFILES_DIR" || exit

MODE="-R"
ACTION_TEXT="Stowing"
DRY_RUN=""

while getopts "unh" opt; do
  case $opt in
  u)
    MODE="-D"
    ACTION_TEXT="Unlinking"
    ;;
  n)
    DRY_RUN="--simulate"
    echo "--- DRY RUN MODE ENABLED ---"
    ;;
  h)
    echo "Usage: ./script.sh [-u] [-n]"
    exit 0
    ;;
  *) exit 1 ;;
  esac
done

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

if [[ "$MODE" == "-R" ]]; then
  mkdir -p "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$HOME/.local/bin"
fi

echo "$ACTION_TEXT shared configurations..."
stow $DRY_RUN -v "$MODE" -d config/common -t "$XDG_CONFIG_HOME" .

if [[ "$(uname -s)" == "Darwin" ]]; then
  echo "$ACTION_TEXT macOS configurations..."
  stow $DRY_RUN -v "$MODE" -d config/macos -t "$XDG_CONFIG_HOME" .
elif [[ "$(uname -s)" == "Linux" ]]; then
  echo "$ACTION_TEXT Linux configurations..."
  stow $DRY_RUN -v "$MODE" -d config/linux -t "$XDG_CONFIG_HOME" .
fi

echo "$ACTION_TEXT home..."
stow $DRY_RUN --dotfiles -v "$MODE" -t "$HOME" home

echo "$ACTION_TEXT bin..."
stow $DRY_RUN -v "$MODE" -t "$HOME/.local/bin" bin

J_LINK="$HOME/.local/bin/j"
if [[ "$MODE" == "-D" ]]; then
  [[ -L "$J_LINK" ]] && [[ -z "$DRY_RUN" ]] && rm "$J_LINK"
elif [[ ! -f "bin/j" ]]; then
  [[ -z "$DRY_RUN" ]] && ln -sf "$DOTFILES_DIR/apps/jira/j" "$J_LINK"
fi

if [[ -d "data" ]]; then
  echo "$ACTION_TEXT data..."
  stow $DRY_RUN -v "$MODE" -t "$XDG_DATA_HOME" data
fi

echo "Done! Dotfiles synchronized."
