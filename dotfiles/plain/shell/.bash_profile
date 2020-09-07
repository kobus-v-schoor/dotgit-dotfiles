#! /bin/bash

export EDITOR=vim
export SUDO_EDITOR=vim
export DIFFPROG='vim -d'

[[ -f ~/.bashrc ]] && . ~/.bashrc
[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && while [[ $? -eq 0 ]]; do startx; done
