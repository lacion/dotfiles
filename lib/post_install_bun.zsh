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

print_header "Step 6: Install Bun"

if command_exists bun; then
  info "Bun already installed. Skipping."
  exit 0
fi

info "Installing Bun via official installer..."
if curl -fsSL https://bun.sh/install | bash > /tmp/bun_install.log 2>&1; then
  info "Bun installation completed."
else
  warn "Bun installation failed. Last 50 lines:"
  tail -n 50 /tmp/bun_install.log >&2 || true
fi

info "If needed, add Bun to PATH by ensuring $HOME/.bun/bin is included."


