# ----------------------------------------------------------------------
# Author: Madalin Popa
# Email: coderustle@madalinpopa.com
# ----------------------------------------------------------------------

# ----------------------------------------------------------------------
# Executable search path
# ----------------------------------------------------------------------
# Define tool locations before using them in PATH
export BUN_INSTALL="${BUN_INSTALL:-$HOME/.bun}"
export NVM_DIR="${NVM_DIR:-$HOME/.config/nvm}"
export GOBIN="${GOBIN:-$HOME/.local/bin}"

export PATH="$HOME/.local/bin:$HOME/.local/sbin:$HOME/.cargo/bin:/usr/local/bin:/usr/local/sbin:$BUN_INSTALL/bin:$GOBIN:$PATH"

# Ensure Go-installed binaries (default GOPATH) are available
export PATH="$HOME/go/bin:$PATH"


# Enable colors for `ls`, etc.
export CLICOLOR=1

# GNU-GPG TTY setting (for GPG support)
export GPG_TTY=$(tty)

# ----------------------------------------------------------------------
# Tool-specific configurations
# ----------------------------------------------------------------------
# Bun, NVM, and GOBIN are defined above to ensure PATH includes them correctly

# ----------------------------------------------------------------------
# Editor settings
# ----------------------------------------------------------------------
# Default editor settings
export EDITOR="nano"
export SUDO_EDITOR="$EDITOR"

# PostgreSQL (guarded)
if command -v brew >/dev/null 2>&1; then
  pg_prefix="$(brew --prefix postgresql@18 2>/dev/null)"
  if [ -n "$pg_prefix" ] && [ -d "$pg_prefix/bin" ]; then
    export PATH="$pg_prefix/bin:$PATH"
  fi
fi

# Python should use UTF-8 encoding for stdin, stdout, stderr
export PYTHONIOENCODING="UTF-8"

# Don’t clear the screen after quitting a manual page
export MANPAGER="less -X"
