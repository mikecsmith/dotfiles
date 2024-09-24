#!/bin/bash

DOTFILES_DIR="$HOME/.dotfiles"  # No external overriding, directly define it
cd $DOTFILES_DIR

echo "Stowing config to $HOME/.config"
stow --dotfiles -v -R --target="$HOME/.config" "config"
echo "Stowing home to $HOME"
stow --dotfiles -v -R --target="$HOME" "home"
echo "Stowing bin to $HOME/.local/bin"
stow --dotfiles -v -R --target="$HOME/.local/bin" "bin"
