
#!/bin/bash

# Install Homebrew
if ! command -v brew &> /dev/null; then
    echo "Homebrew is not installed. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi


# Install Homebrew packages
ACCEPT_EULA=y brew bundle --file=~/.dotfiles/packages.brewfile
