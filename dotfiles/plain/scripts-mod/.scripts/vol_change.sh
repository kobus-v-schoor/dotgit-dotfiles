#! /bin/bash

if [[ $1 == "raise" ]]; then
	act="+"
else
	act="-"
fi

vol=$(amixer set Master 5%"$act" | grep '%' | sed 's/\].*//' | rev | \
	sed 's/\[.*//' | cut -c 2- | rev)

echo $vol >  /tmp/conky_notify
