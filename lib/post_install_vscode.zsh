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

print_header "Step 10: VS Code/Cursor settings"

# Ensure code CLI is available (VS Code) and cursor CLI (Cursor)
if ! command -v code >/dev/null 2>&1; then
  warn "VS Code 'code' CLI not found. You can enable it from the Command Palette: 'Shell Command: Install 'code' command in PATH'"
fi

if ! command -v cursor >/dev/null 2>&1; then
  info "Cursor CLI not found; skipping Cursor-specific sync."
fi

SETTINGS_DIR="$HOME/Library/Application Support/Code/User"
CURSOR_DIR="$HOME/Library/Application Support/Cursor/User"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPO_CFG_DIR="$REPO_ROOT/home/.config/cursor"
REPO_EDITOR_DIR="$REPO_ROOT/home/.config/editor"

# Merge JSON files (left-to-right; later files override earlier ones)
merge_settings_many() {
  local out_json="$1"; shift
  local files=("$@")
  # Filter to existing files only
  local existing=()
  for f in "${files[@]}"; do
    [ -f "$f" ] && existing+=("$f")
  done
  if (( ${#existing[@]} == 0 )); then
    return 1
  fi
  if command -v jq >/dev/null 2>&1; then
    jq -s 'reduce .[] as $item ({}; . * $item)' "${existing[@]}" > "$out_json"
  else
    # Fallback: take the last file as output
    cp "${existing[-1]}" "$out_json"
  fi
}

if [ -d "$REPO_EDITOR_DIR" ]; then
  mkdir -p "$CURSOR_DIR" "$SETTINGS_DIR"
  # Cursor: base -> repo cursor settings.json (if present) -> cursor overlay
  if [ -f "$REPO_EDITOR_DIR/settings.base.json" ]; then
    info "Merging settings for Cursor"
    merge_settings_many "$CURSOR_DIR/settings.json" \
      "$REPO_EDITOR_DIR/settings.base.json" \
      "$REPO_CFG_DIR/settings.json" \
      "$REPO_EDITOR_DIR/settings.cursor.json" || true
  fi
  # VS Code: base -> vscode overlay
  if [ -f "$REPO_EDITOR_DIR/settings.base.json" ]; then
    info "Merging settings for VS Code"
    # Optionally include non-Cursor keys from repo Cursor settings if jq is available
    VS_EXTRA=""
    if [ -f "$REPO_CFG_DIR/settings.json" ] && command -v jq >/dev/null 2>&1; then
      tmp_filtered="$(mktemp)"
      jq 'with_entries(select(.key | startswith("cursor.") | not))' "$REPO_CFG_DIR/settings.json" > "$tmp_filtered" 2>/dev/null || true
      VS_EXTRA="$tmp_filtered"
    fi
    if [ -n "$VS_EXTRA" ]; then
      merge_settings_many "$SETTINGS_DIR/settings.json" \
        "$REPO_EDITOR_DIR/settings.base.json" \
        "$VS_EXTRA" \
        "$REPO_EDITOR_DIR/settings.vscode.json" || true
      rm -f "$VS_EXTRA" 2>/dev/null || true
    else
      merge_settings_many "$SETTINGS_DIR/settings.json" \
        "$REPO_EDITOR_DIR/settings.base.json" \
        "$REPO_EDITOR_DIR/settings.vscode.json" || true
    fi
  fi
fi

info "VS Code setup finished (non-destructive)."

# Install VS Code extensions using unified editor installer if available
if command -v code >/dev/null 2>&1; then
  if [ -f "$REPO_EDITOR_DIR/install-extensions.zsh" ] && [ -f "$REPO_EDITOR_DIR/extensions.txt" ]; then
    info "Installing VS Code extensions from $REPO_EDITOR_DIR/extensions.txt"
    zsh "$REPO_EDITOR_DIR/install-extensions.zsh" --target vscode --extensions-file "$REPO_EDITOR_DIR/extensions.txt" || warn "VS Code extensions install script failed"
  else
    info "Skipping VS Code extension install (unified installer or list not found)."
  fi
else
  info "Skipping VS Code extension install (code CLI not available)."
fi


