# Use powerline
USE_POWERLINE="true"
# Source manjaro-zsh-configuration
if [[ -e /usr/share/zsh/manjaro-zsh-config ]]; then
  source /usr/share/zsh/manjaro-zsh-config
fi
# Use manjaro zsh prompt
if [[ -e /usr/share/zsh/manjaro-zsh-prompt ]]; then
  source /usr/share/zsh/manjaro-zsh-prompt
fi

PS1='[%n@%m %c$(__git_ps1 " (%s)")]\$ '

bindkey -v
alias ls='ls --color=auto'
alias vi='nvim'
alias vim='nvim'
alias bim='nvim'
alias cim='nvim'
alias open='xdg-open'
alias saty='satysfi'
alias tree="pwd;find . | sort | sed '1d;s/^\.//;s/\/\([^/]*\)$/|--\1/;s/\/[^/|]*/| /g'"
alias register="/usr/lib/mozc/mozc_tool --mode=word_register_dialog"
export SYSTEMD_EDITOR=nvim

source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh

# opam configuration
[[ ! -r /home/nkpr/.opam/opam-init/init.zsh ]] || source /home/nkpr/.opam/opam-init/init.zsh  > /dev/null 2> /dev/null
