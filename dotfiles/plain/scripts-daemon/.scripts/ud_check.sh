#! /bin/bash

uds=$(wc -l ~/.updates)

tmp=$(checkupdates)
[[ $tmp ]] && echo "$tmp" > ~/.updates
[[ $tmp ]] || echo -n > ~/.updates

[[ $uds < $(wc -l ~/.updates) ]] && ~/.scripts/notify.sh info 3
