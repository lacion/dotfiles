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

print_header "Step 7: fzf keybindings"

if ! command_exists fzf; then
  warn "fzf not installed; skipping fzf setup"
  exit 0
fi

if [ -x "$(brew --prefix)/opt/fzf/install" ]; then
  info "Installing fzf keybindings (non-interactive)"
  "$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc || warn "fzf install script failed"
else
  warn "fzf install helper not found"
fi

info "fzf setup complete."


