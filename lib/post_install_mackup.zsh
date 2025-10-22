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

print_header "Step 12: Mackup setup"

if ! command_exists mackup; then
  warn "mackup not installed; skipping setup"
  exit 0
fi

# Allow skipping via env flag
if [ -n "${SKIP_MACKUP_BACKUP:-}" ]; then
  info "SKIP_MACKUP_BACKUP set; skipping initial backup and LaunchAgent setup"
  exit 0
fi

# Ensure config exists at $HOME/.mackup.cfg (link step already does this)
if [ ! -f "$HOME/.mackup.cfg" ]; then
  warn "~/.mackup.cfg not found; create it or ensure link step ran"
else
  info "Found ~/.mackup.cfg (storage: $(grep '^engine' "$HOME/.mackup.cfg" 2>/dev/null | awk -F= '{print $2}' | tr -d ' ' || true))"
fi

# Create LaunchAgent to run mackup backup at login and daily
LA_DIR="$HOME/Library/LaunchAgents"
LA_PLIST="$LA_DIR/com.user.mackup.backup.plist"
mkdir -p "$LA_DIR"

# Resolve absolute path for mackup
MACKUP_BIN="$(command -v mackup || echo /opt/homebrew/bin/mackup)"

cat > "$LA_PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.user.mackup.backup</string>
  <key>ProgramArguments</key>
  <array>
    <string>$MACKUP_BIN</string>
    <string>backup</string>
    <string>--force</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>StartInterval</key>
  <integer>86400</integer>
  <key>StandardOutPath</key>
  <string>$HOME/Library/Logs/mackup-backup.log</string>
  <key>StandardErrorPath</key>
  <string>$HOME/Library/Logs/mackup-backup.err</string>
</dict>
</plist>
PLIST

info "Loading LaunchAgent for Mackup backups"
launchctl unload -w "$LA_PLIST" 2>/dev/null || true
launchctl load -w "$LA_PLIST" 2>/dev/null || true

# Pre-create iCloud target directory to avoid shutil errors
ICLOUD_ROOT="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Mackup"
mkdir -p "$ICLOUD_ROOT" 2>/dev/null || true

# Initial backup seed (log errors to file, not the terminal)
info "Running initial mackup backup"
mktmp_log="$(mktemp)"
if ! mackup backup --force >"$mktmp_log" 2>&1; then
  warn "mackup backup failed; see $mktmp_log"
else
  rm -f "$mktmp_log" 2>/dev/null || true
fi

info "Mackup setup complete."


