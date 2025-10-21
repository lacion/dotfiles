#!/usr/bin/env zsh

# Strict mode and sane defaults
set -e
set -u
set -o pipefail
IFS=$'\n\t'

# Function to print a formatted header.
# Usage: print_header "My Header"
print_header() {
  echo ""
  echo "--------------------------------------------------"
  echo "  $1"
  echo "--------------------------------------------------"
}

# Lightweight logging helpers
info()  { printf "%s\n" "  -> $*"; }
warn()  { printf "%s\n" "  !! $*" >&2; }
die()   { printf "%s\n" "  xx $*" >&2; exit 1; }
run()   { info "+ $*"; "$@"; }

# Function to get the operating system.
get_os() {
  case "$(uname -s)" in
    Darwin)
      echo "macos"
      ;;
    Linux)
      if [ -f /etc/os-release ]; then
        . /etc/os-release
        case "$ID" in
          ubuntu|fedora|arch)
            echo "$ID"
            ;;
          *)
            echo "unsupported"
            ;;
        esac
      else
        echo "unsupported"
      fi
      ;;
    *)
      echo "unsupported"
      ;;
  esac
}

# Function to create a symbolic link safely.
create_symlink() {
  local source_path="$1"
  local destination_path="$2"

  if [[ -z "$source_path" || -z "$destination_path" ]]; then
    echo "  -> Error: Both source and destination are required for create_symlink." >&2
    return 1
  fi

  # If the link is already correct, do nothing (compare canonical paths when possible).
  local current_target=""
  if [[ -L "$destination_path" ]]; then
    current_target="$(readlink "$destination_path")"
  fi
  if [[ -n "$current_target" ]] && [[ "$(canonical_path "$current_target")" == "$(canonical_path "$source_path")" ]]; then
    return 0
  fi

  # If the destination exists as something else, remove it.
  if [[ -e "$destination_path" || -L "$destination_path" ]]; then
    echo "  -> Removing existing '$destination_path'"
    rm -rf "$destination_path"
  fi

  # Create the parent directory and the link.
  mkdir -p "$(dirname "$destination_path")"
  ln -s "$source_path" "$destination_path"
  echo "  -> Linked '$destination_path' -> '$source_path'"
}

# Function to check if a command exists.
command_exists() {
  command -v "$1" &>/dev/null
}

# Canonicalize a path with fallbacks (realpath/grealpath/python), or echo input on failure
canonical_path() {
  local p="$1"
  if command_exists realpath; then
    realpath "$p" 2>/dev/null || echo "$p"
    return
  fi
  if command_exists grealpath; then
    grealpath "$p" 2>/dev/null || echo "$p"
    return
  fi
  if command_exists python3; then
    python3 - "$p" <<'PY' 2>/dev/null || echo "$p"
import os, sys
print(os.path.realpath(sys.argv[1]))
PY
    return
  fi
  echo "$p"
}

# Detect Apple Silicon
is_arm64() {
  [[ "$(uname -m)" == "arm64" ]]
}


