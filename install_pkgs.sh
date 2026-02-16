#!/usr/bin/env bash

if ! command -v brew &>/dev/null; then
  echo "Homebrew is not installed. Installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
  test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

if [[ "$(uname -s)" == "Darwin" ]]; then
    echo "Installing macOS-specific packages..."
    ACCEPT_EULA=y brew bundle --file="$HOME/.dotfiles/Brewfile.mac"
elif [[ "$(uname -s)" == "Linux" ]]; then
    echo "Installing Linux-specific packages..."
    ACCEPT_EULA=y brew bundle --file="$HOME/.dotfiles/Brewfile.linux"
fi

echo "All packages installed successfully."
