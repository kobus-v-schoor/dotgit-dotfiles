#! /bin/bash

pkgs=$(grep "'pacman -S " /var/log/pacman.log | rev | sed 's/ S-.*//g' | cut \
-c 2- | rev)

pkgs=$(for i in $pkgs; do echo $i; done | sed 's/ /\n/g')
pkgs=$(for i in $pkgs; do echo $i; done | sort -u)

insll=""
query=$(pacman -Q | sed 's/\ .*//g')
for i in $pkgs; do
	if echo "$query" | grep -q "^$i$"; then
		insll="$insll$i "
	fi
done

for i in $insll; do
	echo $i
done | less
