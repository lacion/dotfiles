#!/usr/bin/env zsh

set -e
set -u
set -o pipefail
IFS=$'\n\t'

if [ -f "$(dirname "$0")/utils.zsh" ]; then
  source "$(dirname "$0")/utils.zsh"
else
  source "$(dirname "$0")/utils.sh"
fi

print_header "Step 9: macOS defaults"

if [ "$(get_os)" != "macos" ]; then
  info "Not macOS; skipping defaults."
  exit 0
fi

info "Tweaking Dock, Finder, and keyboard..."

# Faster key repeat
defaults write -g KeyRepeat -int 2
defaults write -g InitialKeyRepeat -int 15

# Finder: show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Finder: show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Dock: autohide, no recent apps
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock show-recents -bool false

# Restart affected apps
killall Finder Dock SystemUIServer 2>/dev/null || true

info "macOS defaults applied."


