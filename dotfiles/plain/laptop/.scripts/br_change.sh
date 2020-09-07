#! /bin/bash

max=$(cat /sys/class/backlight/intel_backlight/max_brightness)
v=$((max * 10))
v=$((v / 100))

cv=$(cat /sys/class/backlight/intel_backlight/brightness)

if [[ $1 == "+" ]]; then
	((cv += v))
else
	((cv -= v))
fi

[[ $cv -lt 0 ]] && cv=0
[[ $cv -gt $max ]] && cv=$max

echo $cv | sudo tee /sys/class/backlight/intel_backlight/brightness
