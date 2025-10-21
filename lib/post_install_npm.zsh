#!/usr/bin/env zsh

set -e
set -u
set -o pipefail
IFS=$'\n\t'

# --- Source Utilities ---
if [ -f "$(dirname "$0")/utils.zsh" ]; then
  source "$(dirname "$0")/utils.zsh"
else
  source "$(dirname "$0")/utils.sh"
fi

print_header "Step 5: Install npm global packages"

# --- Prerequisite Checks ---
if ! command_exists npm; then
  warn "npm is not installed. Skipping npm global packages."
  exit 0
fi

# Prefer corepack for package manager stability
if command_exists corepack; then
  info "Enabling corepack..."
  corepack enable || true
fi

info "Installing npm global packages..."

PACKAGES=(
  @google/gemini-cli
)

for p in "${PACKAGES[@]}"; do
  info "Installing $p"
  if npm install -g "$p" > /tmp/npm_global_install.log 2>&1; then
    info "$p installed"
  else
    warn "Failed to install $p. Last 50 lines:"
    tail -n 50 /tmp/npm_global_install.log >&2 || true
  fi
done

info "npm global installs complete."


