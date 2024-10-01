# ============================================================================
# ZSH Configuration
# ============================================================================

# Enable ZSH settings
setopt NO_auto_cd            # Disable auto cd (require 'cd' to change dirs)

# Optional ZSH improvements
setopt NO_BEEP               # Disable audible bell
setopt CHECK_JOBS            # Warn if there are background jobs when exiting

# ============================================================================
# Powerlevel10k Theme and Configurations
# ============================================================================

# Load Powerlevel10k theme if Homebrew is installed
if type brew &>/dev/null; then
  source "$(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme"
fi

# Load Powerlevel10k configuration if it exists
if [ -f "$HOME/.config/zsh/p10k.zsh" ]; then
  source "$HOME/.config/zsh/p10k.zsh"
fi

# ============================================================================
# ZSH Completion System Setup
# ============================================================================

# Initialize completion system (stored in XDG cache for cleanliness)
if type brew &>/dev/null; then
  # Add Homebrew's zsh site-functions to the FPATH
  FPATH="$(brew --prefix)/share/zsh/site-functions:$FPATH"

  mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
  autoload -Uz compinit

  compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
fi

# ============================================================================
# Environment Variables
# ============================================================================

# Color settings for 'ls' and other utilities
export LS_COLORS=$(vivid generate one-dark)
export CLICOLOR=1

# Set preferred editor
export EDITOR="vim"         # Default editor (Vim)
export VISUAL="vim"        # Visual editor (VS Code)

# ============================================================================
# ZSH History Configuration
# ============================================================================

# Store history in XDG-compliant location
mkdir -p "${XDG_DATA_HOME:-$HOME/.local/share}/zsh"
export HISTFILE="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/.zsh_history"

# Ignore specific commands from history
export HISTIGNORE="ls:cd:cd -:pwd:exit:date:* --help"

# Control history size
export HISTSIZE=10000       # Number of commands kept in memory
export SAVEHIST=10000       # Number of commands saved to file

# ZSH History Options
setopt HIST_IGNORE_DUPS     # Don't store duplicate commands consecutively
setopt HIST_FIND_NO_DUPS    # Avoid duplicate matches during history search
setopt HIST_IGNORE_SPACE    # Ignore commands that start with a space
setopt INC_APPEND_HISTORY   # Immediately append new commands to the history file
setopt SHARE_HISTORY        # Share history across multiple sessions
setopt EXTENDED_HISTORY     # Store timestamps in history file

# ============================================================================
# Keybindings
# ============================================================================

# Bind arrow keys for history search based on the beginning of a command
bindkey "^[[A" history-beginning-search-backward   # Up Arrow
bindkey "^[[B" history-beginning-search-forward    # Down Arrow

# Bind Ctrl+P/N for more general history search
bindkey '^P' history-search-backward               # Ctrl+P
bindkey '^N' history-search-forward                # Ctrl+N

# ============================================================================
# PATH Configuration
# ============================================================================

export PATH=$(brew --prefix)/opt/libpq/bin:$PATH
export PATH=$HOME/.pnpm-packages/bin:$HOME/.pnpm-packages:$PATH
export PATH=$HOME/.npm-packages/bin:$HOME/bin:$PATH
export PATH=$HOME/.local/bin:$PATH
export PATH=/opt/homebrew/bin:$PATH
export PATH=$PATH:$HOME/.cargo/bin
export PATH=$PATH:$HOME/.luarocks/bin

# ============================================================================
# Useful Aliases
# ============================================================================

# Always use color with 'ls' and group directories first
alias ls="gls --group-directories-first -FHG --color"

# Aliases for Vim and Neovim
alias vi="nvim"              # Alias vi to Neovim
alias vim="nvim"             # Alias Vim to Neovim

# Ripgrep with colored output
alias rg="rg --color=always"

# ============================================================================
# Bindings for Common Commands
# ============================================================================

bindkey "^W" backward-kill-word

# ============================================================================
# External Tool Initialization
# ============================================================================

# Load 'mise' shell environment manager (if applicable)
eval "$(mise activate zsh --shims)"

# Load ZSH autosuggestions from Homebrew (only if Homebrew is installed)
if type brew &>/dev/null; then
  source <(fzf --zsh)
  source "$(brew --prefix)/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh"
  source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" # Must be last thing sourced
fi
