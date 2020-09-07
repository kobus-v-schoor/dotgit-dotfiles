#! /bin/bash

[[ $# -eq 0 ]] && echo Not enough args && exit 1

[[ $1 != "mount" ]] && [[ $1 != "unmount" ]] && echo Invalid operation && exit 1

function usbdevices
{
	for i in /dev/disk/by-path/*usb*; do
		p=$(readlink -e $i)
		[[ $p =~ sd.[1-9]+ ]] && echo $p
	done
}

for i in $(usbdevices); do
	[[ $2 ]] && [[ $i =~ $2 ]] && continue

	if [[ $1 == "mount" ]]; then
		grep -q $i /proc/mounts && continue

		info=$(udisksctl info -b $i)

		opt=

		[[ $info =~ IdType:.*ntfs ]] && opt+="-o dmask=022,fmask=133 "
		[[ $info =~ IdUUID:.*664D-7530 ]] && continue
		[[ $info =~ IdUUID:.*e5fc0eb8-cd8c-438e-974c-41b1bed09425 ]] && continue

		udisksctl mount $opt -b $i
	else
		grep $i /proc/mounts | grep -q /media && udisksctl unmount -b $i
	fi
done
