
# Source configuration files
ZSH_CONFIG="$HOME/.config/zsh"

# oh-my-zsh (load first so custom config overrides)
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git direnv kubectl 1password ansible aws brew bun docker docker-compose fzf gh gnu-utils golang macos postgres python redis-cli ssh stripe sudo zoxide)
if [ -s "$ZSH/oh-my-zsh.sh" ]; then
  source "$ZSH/oh-my-zsh.sh"
fi

for file in "$ZSH_CONFIG"/*.zsh; do
    [ -r "$file" ] && source "$file"
done

# Load machine specific configuration
if [ -f "$HOME/.machine_specific" ]; then
    source "$HOME/.machine_specific"
fi

# Local aliasses
if [ -f "$HOME/.local_aliases" ]; then
    . "$HOME/.local_aliases"
fi
# bun completions
[ -s "/Users/luismorales/.bun/_bun" ] && source "/Users/luismorales/.bun/_bun"
