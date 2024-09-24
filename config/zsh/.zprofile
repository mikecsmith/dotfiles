# Add Homebrew to PATH
export PATH="/opt/homebrew/bin:$PATH"  # Use /usr/local/bin if on Intel Mac

# Optionally, initialize Homebrew
if command -v brew &>/dev/null; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

eval "$(mise activate zsh --shims)"
