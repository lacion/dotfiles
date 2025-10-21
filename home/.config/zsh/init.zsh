# ----------------------------------------------------------------------
# Homebrew configuration
# Add Homebrew binaries to the PATH, depending on the installation path.
# ----------------------------------------------------------------------
if [[ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [[ -f "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ----------------------------------------------------------------------
# oh-my-zsh handles autosuggestions if plugin enabled; otherwise fallback
# ----------------------------------------------------------------------
if [[ -z "${ZSH:-}" ]]; then
  if command -v brew &> /dev/null; then
    source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  fi
else
  # oh-my-zsh path-based fallback if plugin not installed via OMZ
  if [ -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
    source "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
  fi
fi

# ----------------------------------------------------------------------
# ZSH auto-suggestions
# ----------------------------------------------------------------------
if [ -f /etc/os-release ]; then
  . /etc/os-release
  if [ "$ID" = "arch" ]; then
    # Arch Linux specific config
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
  fi
fi