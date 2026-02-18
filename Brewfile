require 'socket'
hostname = Socket.gethostname

brew "bat"
brew "bkt"
brew "btop"
brew "eza"
brew "fd"
brew "fzf"
brew "gh"
brew "git"
brew "git-absorb"
brew "jq"
brew "lazygit"
brew "parallel"
brew "starship"
brew "stow"
brew "ripgrep"
brew "vivid" # Colorizer for LS_COLORS
brew "yq"
brew "zsh-autosuggestions"
brew "zsh-syntax-highlighting"
brew "zsh-vi-mode"
brew "zoxide"

if OS.linux?
end

if OS.mac?
  # Formulae
  brew "awscli"
  brew "argocd"
  brew "bash"
  brew "colima"
  brew "difftastic"
  brew "docker"
  brew "docker-credential-helper"
  brew "dockutil"
  brew "gs"
  brew "imagemagick"
  brew "libpq"
  brew "mermaid-cli"
  brew "mise" # included by default in uBlue OSes
  brew "pandoc"
  brew "pgcli"
  brew "sqlcmd"
  brew "tectonic"
  brew "tilt"
  brew "tilt-dev/tap/ctlptl"
  brew "tlrc" # tldr package
  brew "unixodbc"
  brew "utftex"
  brew "wget"
  brew "zip"

  # Casks
  cask "1password-cli"
  cask "alt-tab"
  cask "bruno"
  cask "font-codicon"
  cask "iina"
  cask "kitty"
  cask "quarto"
  cask "raycast"
  cask "visual-studio-code"

  # Nerd Fonts
  cask "font-meslo-lg-nerd-font"

  # Personal
  if hostname.start_with?("orcus")
    brew "hivemq/mqtt-cli/mqtt-cli"
    brew "siderolabs/tap/omnictl"
    brew "siderolabs/tap/talosctl"

    cask "arc"
  end
end
