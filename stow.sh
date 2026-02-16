#!/usr/bin/env bash

DOTFILES_DIR="$HOME/.dotfiles"
cd "$DOTFILES_DIR" || exit

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

mkdir -p "$XDG_CONFIG_HOME"
mkdir -p "$XDG_DATA_HOME"
mkdir -p "$HOME/.local/bin"

# 1. Common Config
echo "Stowing shared configurations..."
stow -v -R -d config/common -t "$XDG_CONFIG_HOME" .

# 2. Platform-Specific Config
if [[ "$(uname -s)" == "Darwin" ]]; then
    echo "Stowing macOS configurations..."
    stow -v -R -d config/macos -t "$XDG_CONFIG_HOME" .
elif [[ "$(uname -s)" == "Linux" ]]; then
    echo "Stowing Linux configurations..."
    stow -v -R -d config/linux -t "$XDG_CONFIG_HOME" .
fi

# 3. Universal Folders (using --dotfiles for the dot- prefix conversion)
echo "Stowing home..."
stow --dotfiles -v -R -t "$HOME" home

echo "Stowing bin..."
# If Stow still complains about 'j', it's because it's still there. 
# Added --adopt as a safety net, but usually 'rm' is better.
stow -v -R -t "$HOME/.local/bin" bin

# Only run this if 'j' ISN'T already in your .dotfiles/bin folder
if [[ ! -f "bin/j" ]]; then
    ln -sf "$DOTFILES_DIR/apps/jira/j" "$HOME/.local/bin/j"
fi

# 4. Data (Check if directory exists first to avoid the data package error)
if [[ -d "data" ]]; then
    echo "Stowing data..."
    stow -v -R -t "$XDG_DATA_HOME" data
fi

echo "Done! Dotfiles synchronized."
