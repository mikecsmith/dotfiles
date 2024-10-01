#!/bin/bash

# Set defaults for NSGlobalDomain
defaults write NSGlobalDomain AppleShowAllExtensions -bool true         # Show all file extensions in Finder
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false      # Disable press and hold for keys in favor of key repeat
defaults write NSGlobalDomain KeyRepeat -int 2                          # Set the key repeat rate (lower is faster)
defaults write NSGlobalDomain InitialKeyRepeat -int 15                  # Set the delay until key repeat starts (lower is shorter)
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1        # Enable tap to click for the mouse
defaults write NSGlobalDomain com.apple.sound.beep.volume -float 0.0    # Set beep volume to 0 (mute)
defaults write NSGlobalDomain com.apple.sound.beep.feedback -bool false # Disable beep feedback

# Set defaults for Dock
defaults write com.apple.dock autohide -bool true                  # Auto-hide the Dock
defaults write com.apple.dock show-recents -bool false             # Do not show recent applications in the Dock
defaults write com.apple.dock launchanim -bool false               # Disable the animation when launching applications from the Dock
defaults write com.apple.dock orientation -string "left"           # Set Dock position to left of the screen
defaults write com.apple.dock tilesize -int 24                     # Set Dock tile size
defaults write com.apple.dock mru-spaces -bool false               # Disable "most recently used" spaces
defaults write com.apple.dock expose-animation-duration -float 0.1 # Set Expose animation duration

# Set defaults for Finder
defaults write com.apple.finder _FXShowPosixPathInTitle -bool false # Do not show full POSIX path in the title

# Set defaults for screencapture
defaults write com.apple.screencapture location -string "${HOME}/Pictures/Screenshots" # Set the location for saved screenshots

# Set defaults for trackpad
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true                # Enable tap to click for the trackpad
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true # Enable three-finger drag for the trackpad

# Apply the changes
killall Finder         # Restart Finder to apply changes
killall Dock           # Restart Dock to apply changes
killall SystemUIServer # Restart SystemUIServer to apply changes

echo "System preferences have been updated."
