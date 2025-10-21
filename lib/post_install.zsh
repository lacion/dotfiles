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

print_header "Step 4: Running Post-Installation Tasks"

# --- Create Local User Files ---
info "Ensuring local user files exist..."
files_to_create=(".hushlogin" ".local_aliases" ".machine_specific" ".gitconfig_local")

for file in "${files_to_create[@]}"; do
  if [ ! -f "$HOME/$file" ]; then
    run touch "$HOME/$file"
    # Restrict sensitive files
    case "$file" in
      .gitconfig_local)
        chmod 600 "$HOME/$file" || true
        ;;
    esac
  fi
done

info "Post-install tasks complete."


