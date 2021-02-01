# prevent from duplicate records in path
typeset -U path
path=('/usr/local/bin' $path)
export ZSH="/Users/luismorales/.oh-my-zsh"
ZSH_THEME="oxide"

plugins=(
    git 
    ansible 
    aws 
    brew 
    celery 
    direnv 
    docker-compose 
    docker 
    gcloud 
    golang 
    kubectl 
    npm 
    node 
    pip 
    python 
    terraform 
    virtualenv 
    yarn
    zsh-256color
    zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

# Setup online help (recommended by homebrew)
unalias run-help &> /dev/null
autoload run-help
autoload -U zmv
HELPDIR=/usr/local/share/zsh/helpfiles

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANG="es_ES.UTF-8"
export LANGUAGE="es_ES.UTF-8"
export LC_ALL="es_ES.UTF-8"

alias r="source ~/.zshrc"
alias brewup="brew update; brew upgrade"
alias pyhttp="python -m SimpleHTTPServer"
alias npmupdate="npm update -g npm"
alias npmupdateall="npm update -g"
alias sed=gsed

export PATH="/usr/local/bin:${PATH}"