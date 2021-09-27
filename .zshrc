PS1='%B%F{red}%(?^^%? )%f%b%n@%M:%~ %# '
bindkey -v
alias ls='ls --color=auto'
alias vi='nvim'
alias vim='nvim'
alias bim='nvim'
alias open='xdg-open'
alias saty='satysfi'
alias tree="pwd;find . | sort | sed '1d;s/^\.//;s/\/\([^/]*\)$/|--\1/;s/\/[^/|]*/| /g'"
export SYSTEMD_EDITOR=nvim
source $HOME/.zprofile

# opam configuration
[[ ! -r /home/nk86/.opam/opam-init/init.zsh ]] || source /home/nk86/.opam/opam-init/init.zsh  > /dev/null 2> /dev/null

autoload -U compinit
compinit
