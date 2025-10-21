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

print_header "Step 2: Installing Apps via Homebrew Bundle"

# --- Prerequisite Checks ---
if [ "$(get_os)" != "macos" ]; then
  info "Skipping, not on macOS."
  exit 0
fi

if ! command_exists brew; then
  warn "Homebrew (brew) command not found. Skipping bundle."
  exit 0
fi

# --- Bundle Brewfile ---
info "Installing apps from Brewfile. This may take a while..."

export HOMEBREW_NO_AUTO_UPDATE=1

# Profile support: INSTALL_PROFILE=work|personal selects Brewfile.<profile> if present
ROOT_PATH="$(cd "$(dirname "$0")/.." && pwd)"
DEFAULT_BREWFILE="$ROOT_PATH/Brewfile"
PROFILE_BREWFILE="${DEFAULT_BREWFILE}.${INSTALL_PROFILE:-}"

if [ -n "${INSTALL_PROFILE:-}" ] && [ -f "$PROFILE_BREWFILE" ]; then
  BREWFILE_PATH="$PROFILE_BREWFILE"
else
  BREWFILE_PATH="$DEFAULT_BREWFILE"
fi

if [ ! -f "$BREWFILE_PATH" ]; then
  die "Brewfile not found at $BREWFILE_PATH"
fi

START_TS=$(date +%s)
if brew bundle install --file="$BREWFILE_PATH" > /tmp/brew_bundle.log 2>&1; then
  info "brew bundle completed successfully."
else
  warn "brew bundle encountered an error. Last 50 lines:" && tail -n 50 /tmp/brew_bundle.log >&2 || true
fi

if [[ "${BREW_BUNDLE_CLEANUP:-0}" == "1" ]]; then
  info "Running brew bundle cleanup..."
  brew bundle cleanup --force --file="$BREWFILE_PATH" || warn "brew bundle cleanup failed"
fi

END_TS=$(date +%s)
info "brew bundle duration: $((END_TS-START_TS))s"


