#!/usr/bin/env zsh

set -e
set -u
set -o pipefail
IFS=$'\n\t'

# --- Setup ---
# Get the root directory of the dotfiles repository.
readonly ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
readonly LIB_PATH="${ROOT_PATH}/lib"
if [ -f "${LIB_PATH}/utils.zsh" ]; then
  source "${LIB_PATH}/utils.zsh"
else
  source "${LIB_PATH}/utils.sh"
fi

# --- Sudo Password Prompt ---
print_header "Checking for sudo access..."
echo "This script may require sudo access for some installation steps."
if sudo -n true 2>/dev/null; then
  :
else
  sudo -v
fi

# Keep-alive sudo session with cleanup
start_sudo_keepalive() {
  ( while kill -0 "$PPID" 2>/dev/null; do sudo -n true || exit; sleep 60; done ) &
  SUDO_KEEPALIVE_PID=$!
}
stop_sudo_keepalive() { [[ -n "${SUDO_KEEPALIVE_PID:-}" ]] && kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true; }
trap stop_sudo_keepalive EXIT
start_sudo_keepalive

# --- Installation Steps ---
print_header "Starting Dotfiles Installation"

# Step 0: Xcode CLT (macOS)
if [ -f "${LIB_PATH}/xcode.zsh" ]; then
    zsh "${LIB_PATH}/xcode.zsh"
fi

# Step 1: Bootstrap (Install Homebrew)
if [ -f "${LIB_PATH}/bootstrap.zsh" ]; then
    zsh "${LIB_PATH}/bootstrap.zsh"
fi

# Step 2: Install applications using Brewfile
if [ -f "${LIB_PATH}/brew.zsh" ]; then
    zsh "${LIB_PATH}/brew.zsh"
fi

# Step 3: Create symbolic links
if [ -f "${LIB_PATH}/link.zsh" ]; then
    zsh "${LIB_PATH}/link.zsh"
fi

# Step 4: Run post-installation scripts
if [ -f "${LIB_PATH}/post_install.zsh" ]; then
    zsh "${LIB_PATH}/post_install.zsh"
fi

if [ -f "${LIB_PATH}/post_install_npm.zsh" ]; then
    zsh "${LIB_PATH}/post_install_npm.zsh"
fi

if [ -f "${LIB_PATH}/post_install_bun.zsh" ]; then
    zsh "${LIB_PATH}/post_install_bun.zsh"
fi

# Optional post-install steps (default ON, opt-out with SKIP_* flags)
if [ -z "${SKIP_FZF_SETUP:-}" ] && [ -f "${LIB_PATH}/post_install_fzf.zsh" ]; then
    zsh "${LIB_PATH}/post_install_fzf.zsh"
fi

if [ -z "${SKIP_SSH_SETUP:-}" ] && [ -f "${LIB_PATH}/post_install_ssh.zsh" ]; then
    zsh "${LIB_PATH}/post_install_ssh.zsh"
fi

if [ -z "${SKIP_MACOS_TWEAKS:-}" ] && [ -f "${LIB_PATH}/macos_defaults.zsh" ]; then
    zsh "${LIB_PATH}/macos_defaults.zsh"
fi

if [ -z "${SKIP_VSCODE_SETUP:-}" ] && [ -f "${LIB_PATH}/post_install_vscode.zsh" ]; then
    zsh "${LIB_PATH}/post_install_vscode.zsh"
fi

if [ -z "${SKIP_CURSOR_SETUP:-}" ] && [ -f "${LIB_PATH}/post_install_cursor.zsh" ]; then
    zsh "${LIB_PATH}/post_install_cursor.zsh"
fi

# oh-my-zsh installation (default ON; after linking files so .zshrc is present)
if [ -z "${SKIP_OHMYZSH_SETUP:-}" ] && [ -f "${LIB_PATH}/post_install_ohmyzsh.zsh" ]; then
    zsh "${LIB_PATH}/post_install_ohmyzsh.zsh"
fi

# Mackup setup (default ON; ensure config and schedule backup)
if [ -z "${SKIP_MACKUP_SETUP:-}" ] && [ -f "${LIB_PATH}/post_install_mackup.zsh" ]; then
    zsh "${LIB_PATH}/post_install_mackup.zsh"
fi

print_header "Installation Complete!"
echo "Please restart your terminal for all changes to take effect."