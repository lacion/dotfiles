#!/usr/bin/env zsh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

TARGET="auto" # cursor|vscode|both|auto
EXTENSIONS_FILE="${SCRIPT_DIR}/extensions.txt"

usage() {
  echo "Unified Extensions Installer"
  echo ""
  echo "Usage: $0 [--target cursor|vscode|both|auto] [--extensions-file PATH]"
  echo ""
  echo "Defaults: --target auto (detect installed CLIs), --extensions-file ${SCRIPT_DIR}/extensions.txt"
}

# Parse args
while (( $# > 0 )); do
  case "$1" in
    --target)
      shift
      TARGET="${1:-auto}"
      ;;
    --extensions-file)
      shift
      EXTENSIONS_FILE="${1:-$EXTENSIONS_FILE}"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
  shift
done

if [ ! -f "$EXTENSIONS_FILE" ]; then
  echo "❌ Extensions file '$EXTENSIONS_FILE' not found." >&2
  exit 1
fi

has_cursor=0
has_code=0
if command -v cursor >/dev/null 2>&1; then has_cursor=1; fi
if command -v code >/dev/null 2>&1; then has_code=1; fi

case "$TARGET" in
  auto)
    if (( has_cursor == 0 && has_code == 0 )); then
      echo "❌ Neither 'cursor' nor 'code' CLI found in PATH." >&2
      exit 1
    fi
    ;;
  cursor)
    if (( has_cursor == 0 )); then
      echo "❌ 'cursor' CLI not found. Install or add to PATH." >&2
      exit 1
    fi
    ;;
  vscode)
    if (( has_code == 0 )); then
      echo "❌ 'code' CLI not found. In VS Code: install 'code' command in PATH." >&2
      exit 1
    fi
    ;;
  both)
    if (( has_cursor == 0 && has_code == 0 )); then
      echo "❌ Neither 'cursor' nor 'code' CLI found in PATH." >&2
      exit 1
    fi
    ;;
  *)
    echo "❌ Invalid --target: $TARGET" >&2
    usage
    exit 1
    ;;
esac

install_for_cli() {
  local cli_name="$1" # cursor|code
  local cli_bin="$2"
  local -a failed=()

  local total_extensions current
  total_extensions=$(grep -v '^$\|^#' "$EXTENSIONS_FILE" | wc -l | tr -d ' ')
  current=0

  echo "📦 [$cli_name] Installing $total_extensions extensions from $EXTENSIONS_FILE"
  echo ""

  while IFS= read -r extension; do
    if [[ -z "$extension" || "$extension" == \#* ]]; then
      continue
    fi
    current=$((current + 1))
    echo "[$current/$total_extensions][$cli_name] Installing: $extension"
    if "$cli_bin" --install-extension "$extension" --force > /dev/null 2>&1; then
      echo "✅ [$cli_name] $extension"
    else
      echo "❌ [$cli_name] $extension"
      failed+=("$extension")
    fi
    echo ""
  done < "$EXTENSIONS_FILE"

  if (( ${#failed[@]} == 0 )); then
    echo "✅ [$cli_name] All extensions installed successfully!"
  else
    echo "⚠️  [$cli_name] ${#failed[@]} extension(s) failed to install:" >&2
    for f in "${failed[@]}"; do
      echo "  - $f" >&2
    done
  fi

  case "$cli_name" in
    cursor)
      echo "Run 'cursor --list-extensions' to verify installed extensions."
      ;;
    code)
      echo "Run 'code --list-extensions' to verify installed extensions."
      ;;
  esac
}

echo "🔧 Unified Extensions Installer"
echo "==============================="

if [[ "$TARGET" == "auto" || "$TARGET" == "both" ]]; then
  (( has_cursor == 1 )) && install_for_cli "cursor" cursor || true
  (( has_code == 1 )) && install_for_cli "code" code || true
elif [[ "$TARGET" == "cursor" ]]; then
  install_for_cli "cursor" cursor
elif [[ "$TARGET" == "vscode" ]]; then
  install_for_cli "code" code
fi

echo "🎉 Installation process complete!"


