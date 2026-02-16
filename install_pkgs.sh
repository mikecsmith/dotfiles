#!/usr/bin/env bash

if ! command -v brew &>/dev/null; then
  echo "Homebrew is not installed. Installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
  test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

echo "Installing common packages..."
brew bundle --file="$HOME/.dotfiles/base.brewfile"

if [[ "$(uname -s)" == "Darwin" ]]; then
    echo "Installing macOS-specific packages..."
    ACCEPT_EULA=y brew bundle --file="$HOME/.dotfiles/mac.brewfile"
elif [[ "$(uname -s)" == "Linux" ]]; then
    if [[ -f "$HOME/.dotfiles/linux.brewfile" ]]; then
        echo "Installing Linux-specific packages..."
        brew bundle --file="$HOME/.dotfiles/linux.brewfile"
    fi
fi

echo "All packages installed successfully."
