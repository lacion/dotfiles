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

print_header "Step 3: Creating symbolic links"

# Determine repository root and home dir path in repo
ROOT_PATH="$(cd "$(dirname "$0")/.." && pwd)"
REPO_HOME_PATH="$ROOT_PATH/home"

# Profile support: home/<profile> overrides if exists and INSTALL_PROFILE is set
if [ -n "${INSTALL_PROFILE:-}" ] && [ -d "$REPO_HOME_PATH/${INSTALL_PROFILE}" ]; then
  REPO_HOME_PATH="$REPO_HOME_PATH/${INSTALL_PROFILE}"
  info "Using profile: ${INSTALL_PROFILE}"
fi

if [ ! -d "$REPO_HOME_PATH" ]; then
  info "No 'home' directory found in repository. Skipping links."
  exit 0
fi

info "Linking files from $REPO_HOME_PATH to $HOME"

# Link regular files and symlinks; create parent directories as needed
# Excludes common OS metadata files
EXCLUDES='(.DS_Store|.Trash|Icon\r|Thumbs.db)'
count_linked=0
count_skipped=0
count_removed=0

while IFS= read -r source_path; do
  relative_path="${source_path#$REPO_HOME_PATH/}"
  destination_path="$HOME/$relative_path"

  case "$relative_path" in
    *.DS_Store)
      continue
      ;;
    .config/cursor/settings.json)
      # Managed via merged editor settings, not symlinked from repo
      continue
      ;;
  esac

  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    info "Would link '$destination_path' -> '$source_path'"
    count_skipped=$((count_skipped+1))
  else
    if [[ -e "$destination_path" || -L "$destination_path" ]]; then
      # Track removals, the function will remove it
      count_removed=$((count_removed+1))
    fi
    create_symlink "$source_path" "$destination_path"
    count_linked=$((count_linked+1))
  fi
done < <(find "$REPO_HOME_PATH" -mindepth 1 \( -type f -o -type l \) | grep -Ev "$EXCLUDES" | sort)

info "Linking complete. linked=$count_linked removed=$count_removed dry_run_skipped=$count_skipped"


