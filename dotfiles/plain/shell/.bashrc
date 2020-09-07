[[ $- != *i* ]] && return

HISTCONTROL=ignoreboth

shopt -s checkwinsize
shopt -s autocd
shopt -s histappend

alias v=vim
alias sv='sudoedit'

alias ls='ls -lh --color=auto'
alias lsa='ls -lha --color=auto'
alias sl=ls

alias grep='grep --color=auto'
alias rm='rm -I'
alias du='du -h'

alias pword=$'hexdump -v -e \'/1 "%02X"\' -n 40 /dev/random && echo'

# PS1='\[\033[38;5;75m\]\u@\h\[\033[00m\]:\[\033[38;5;248m\]\w\[\033[00m\]\$ '
PS1='\[\033[38;5;249m\]\u@\[\033[38;5;202m\]\h\[\033[00m\]:\[\033[38;5;248m\]\w\[\033[00m\]\$ '

source /usr/share/bash-completion/bash_completion
[ -f ~/.bash_extra ] && source ~/.bash_extra
[ -f ~/.bash_local ] && source ~/.bash_local
