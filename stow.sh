#!/usr/bin/env bash

DOTFILES_DIR="$HOME/.dotfiles" # No external overriding, directly define it
cd "$DOTFILES_DIR" || exit

ln -sf "../apps/jira/j" "bin/j"

echo "Stowing config to $XDG_CONFIG_HOME"
stow --dotfiles -v -R --ignore="config/colima" --target="$XDG_CONFIG_HOME" "config"
stow -v -R --target="$XDG_CONFIG_HOME" "config/colima/default/config.yaml"
echo "Stowing home to $HOME"
stow --dotfiles -v -R --target="$HOME" "home"
echo "Stowing bin to $HOME/.local/bin"
stow --dotfiles -v -R --target="$HOME/.local/bin" "bin"
echo "Stowing XDG_DATA to $XDG_DATA_HOME"
stow --dotfiles -v -R --target="$XDG_DATA_HOME" "data"
