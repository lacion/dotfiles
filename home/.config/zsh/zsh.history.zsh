#!/usr/bin/env zsh

# History Configuration
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
WORDCHARS='*?_-[]~&;!#$%^(){}<>|'

# History Options
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups
setopt hist_verify


# Ignore wrong commands from history
zshaddhistory() { whence ${${(z)1}[1]} >| /dev/null || return 1 }