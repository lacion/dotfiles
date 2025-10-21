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

print_header "Step 0: Xcode Command Line Tools"

if [ "$(get_os)" != "macos" ]; then
  info "Skipping, not on macOS."
  exit 0
fi

if xcode-select --print-path &>/dev/null; then
  info "Command Line Tools already installed."
else
  info "Command Line Tools not found. Launching installer..."
  # This opens a GUI installer and returns immediately
  xcode-select --install || true
  warn "Command Line Tools installer launched. Complete installation, then re-run ./install.zsh if needed."
fi


