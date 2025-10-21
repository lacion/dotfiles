# ----------------------------------------------------------------------
# Tools: zoxide + fzf bindings
# ----------------------------------------------------------------------

# zoxide (smarter cd) — skip if oh-my-zsh plugin is active
if ! typeset -f omz_plugins &>/dev/null || [[ " ${plugins:-} " != *" zoxide "* ]]; then
  if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
    alias zc='zi'
  fi
fi

# fzf keybindings — skip if oh-my-zsh plugin is active
if ! typeset -f omz_plugins &>/dev/null || [[ " ${plugins:-} " != *" fzf "* ]]; then
  if [ -f ~/.fzf.zsh ]; then
    source ~/.fzf.zsh
  fi
fi


