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

print_header "Step 1: Bootstrapping System (Homebrew)"

# --- OS Check ---
if [ "$(get_os)" != "macos" ]; then
  info "Skipping Homebrew installation on non-macOS system."
  exit 0
fi

# --- Check for Homebrew ---
if command_exists brew; then
  info "Homebrew is already installed. Updating..."
  if ! brew update; then
    warn "brew update failed; continuing"
  fi
else
  info "Homebrew not found. Starting installation..."
  export NONINTERACTIVE=1
  if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" > /tmp/brew_install.log 2>&1; then
    info "Homebrew installation finished."
  else
    warn "Homebrew install script failed. Showing last 50 lines:"
    tail -n 50 /tmp/brew_install.log >&2 || true
  fi

  info "Adding Homebrew to your shell environment..."
  if is_arm64; then
    eval "$([[ -x /opt/homebrew/bin/brew ]] && /opt/homebrew/bin/brew shellenv || /usr/local/bin/brew shellenv)"
    BREW_BIN="${HOMEBREW_PREFIX:-/opt/homebrew}/bin/brew"
  else
    eval "$([[ -x /usr/local/bin/brew ]] && /usr/local/bin/brew shellenv || /opt/homebrew/bin/brew shellenv)"
    BREW_BIN="${HOMEBREW_PREFIX:-/usr/local}/bin/brew"
  fi

  for f in "$HOME/.zprofile" "$HOME/.zshrc"; do
    if [ -f "$f" ]; then
      grep -q 'brew shellenv' "$f" 2>/dev/null || printf '\n# Homebrew\neval "$(%s shellenv)"\n' "$BREW_BIN" >> "$f"
    else
      printf '# Homebrew\neval "$(%s shellenv)"\n' "$BREW_BIN" > "$f"
    fi
  done

  # Hint about Rosetta for Apple Silicon
  if is_arm64; then
    info "Apple Silicon detected. If you need Intel-only tools under Rosetta:"
    info "  softwareupdate --install-rosetta --agree-to-license"
  fi

  info "Verifying Homebrew installation..."
  brew doctor > /tmp/brew_doctor.log 2>&1 || warn "brew doctor reported issues; see /tmp/brew_doctor.log"
fi

info "Bootstrap complete."


