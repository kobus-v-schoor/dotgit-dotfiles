#! /bin/bash

polybar-msg hook notify-$1 $2
sleep 10
polybar-msg hook notify-$1 1
