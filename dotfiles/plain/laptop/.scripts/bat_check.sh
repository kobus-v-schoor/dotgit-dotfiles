#! /bin/bash

low_alert=20
crit_alert=10
crit=5

prev=0

while true; do
	sleep 1s
	cur=$(cat /sys/class/power_supply/BAT0/capacity)
	[[ $prev -eq 0 ]] && prev=$cur

	if [[ $prev -gt $low_alert ]]; then
		[[ $cur -le $low_alert ]] && ~/.scripts/notify.sh alert 2
	elif [[ $prev -gt $crit_alert ]]; then
		[[ $cur -le $crit_alert ]] && ~/.scripts/notify.sh urgent 2
	elif [[ $prev -gt $crit ]]; then
		[[ $cur -le $crit ]] && prev=$cur && systemctl suspend
	fi

	prev=$cur
done
