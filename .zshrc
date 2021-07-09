PS1='%B%F{red}%(?^^%? )%f%b%n@%M:%~ %# '
bindkey -v
alias ls='ls --color=auto'
alias vim='nvim'
alias open='xdg-open'

alias tree="pwd;find . | sort | sed '1d;s/^\.//;s/\/\([^/]*\)$/|--\1/;s/\/[^/|]*/| /g'"
