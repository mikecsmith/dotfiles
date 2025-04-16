#!/bin/bash

DOTFILES_DIR="$HOME/.dotfiles" # No external overriding, directly define it
cd "$DOTFILES_DIR" || exit

echo "Stowing config to $HOME/.config"
stow --dotfiles -v -R --target="$HOME/.config" "config"
echo "Stowing home to $HOME"
stow --dotfiles -v -R --target="$HOME" "home"
echo "Stowing bin to $HOME/.local/bin"
stow --dotfiles -v -R --target="$HOME/.local/bin" "bin"

# TODO: Write bootstrap util for j and add to install scripts
echo "Symlinking j to $HOME/.local/bin"
ln -sf "$DOTFILES_DIR/apps/jira/j" "$HOME/.local/bin/j"
