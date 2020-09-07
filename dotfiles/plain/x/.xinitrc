#! /bin/bash

xrdb ~/.Xresources &

xset r rate 400 40 &
setxkbmap -option caps:escape
# xmodmap -e 'keycode 134 = Menu' &> /dev/null

[ -f ~/.scripts/bat_check.sh ] && ~/.scripts/bat_check.sh &
[ -f ~/.scripts/bat_eta.py ] && ~/.scripts/bat_eta.py &
# [ -f ~/.scripts/gmail.sh ] && ~/.scripts/gmail.sh &

numlockx &
# $HOME/.fehbg &
# compton -b --config ~/.config/compton.conf
# compton --backend glx &

exec ~/.scripts/start_wm.sh
