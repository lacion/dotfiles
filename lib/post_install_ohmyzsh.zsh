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

print_header "Step 11: oh-my-zsh installation"

# Preconditions
if ! command_exists zsh; then
  die "zsh not installed. Install zsh first (via brew)."
fi
if ! command_exists git; then
  die "git is required to install oh-my-zsh."
fi
if ! command_exists curl && ! command_exists wget; then
  die "curl or wget is required to install oh-my-zsh."
fi

if [ -d "$HOME/.oh-my-zsh" ]; then
  info "oh-my-zsh already installed. Skipping."
  exit 0
fi

info "Installing oh-my-zsh (unattended)..."
# Ensure installer does not run zsh, does not chsh, and keeps existing .zshrc
export RUNZSH=no
export CHSH=no
export KEEP_ZSHRC=yes
export ZSH="$HOME/.oh-my-zsh"
if command_exists curl; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || warn "oh-my-zsh install script failed"
elif command_exists wget; then
  sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || warn "oh-my-zsh install script failed"
else
  die "curl or wget is required to install oh-my-zsh."
fi

info "oh-my-zsh installation step complete."

# Restore repo-managed .zshrc symlink if the installer replaced it
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPO_ZSHRC="$REPO_ROOT/home/.zshrc"
if [ -f "$REPO_ZSHRC" ]; then
  if [ ! -L "$HOME/.zshrc" ] || [ "$(readlink "$HOME/.zshrc" 2>/dev/null || echo)" != "$REPO_ZSHRC" ]; then
    info "Restoring .zshrc symlink to repository version"
    create_symlink "$REPO_ZSHRC" "$HOME/.zshrc"
  fi
fi


