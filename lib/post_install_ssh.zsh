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

print_header "Step 8: SSH bootstrap"

SSH_DIR="$HOME/.ssh"
KEY_FILE="$SSH_DIR/id_ed25519"

mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

if [ ! -f "$KEY_FILE" ]; then
  info "Generating new ed25519 SSH key..."
  ssh-keygen -t ed25519 -N "" -f "$KEY_FILE" -C "$(whoami)@$(hostname)" || warn "ssh-keygen failed"
fi

eval "$(ssh-agent -s)" >/dev/null 2>&1 || true
# Prefer modern Apple keychain flag; fallback to -K for older systems
if ssh-add --help 2>&1 | grep -q -- '--apple-use-keychain'; then
  ssh-add --apple-use-keychain "$KEY_FILE" 2>/dev/null || ssh-add "$KEY_FILE" || true
else
  ssh-add -K "$KEY_FILE" 2>/dev/null || ssh-add "$KEY_FILE" || true
fi

info "SSH bootstrap complete. Public key:" 
info "$(cat "$KEY_FILE.pub" 2>/dev/null || true)"


