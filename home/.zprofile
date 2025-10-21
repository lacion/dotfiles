#!/bin/zsh

# ----------------------------------------------------------------------
# This file is sourced only for login shells. It's the place for
# commands that should be run only once, at the beginning of a session,
# such as setting environment variables.
# ----------------------------------------------------------------------

# Source environment variables from a dedicated file
if [ -f ~/.config/zsh/exports.zsh ]; then
  source ~/.config/zsh/exports.zsh
fi

# Homebrew configuration
if [[ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [[ -f "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi