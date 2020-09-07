#! /usr/bin/python3

import os
import time
import numpy as np

BAT = "BAT0"
CUR_CHARGE = "/sys/class/power_supply/{}/charge_now".format(BAT)
FULL_CHARGE = "/sys/class/power_supply/{}/charge_full".format(BAT)
AC_ON = "/sys/class/power_supply/{}/status".format(BAT)
INT = 60
LOW = 0.05
FLUSH = 10
MIN = 10

M_HIST = "{}/.cache/bat".format(os.environ["HOME"])
MC_HIST = "{}/.cache/bat_charge".format(os.environ["HOME"])
STAT = "/tmp/bat_rem"

with open(M_HIST, "r") as f:
    MGRAD = [float(x) for x in f.readlines()]
with open(MC_HIST, "r") as f:
    MCGRAD = [float(x) for x in f.readlines()]

MGRAD = np.mean(MGRAD)
MCGRAD = np.mean(MCGRAD)

with open(FULL_CHARGE, "r") as f:
    FULL = int(f.read().strip())

def level():
    with open(CUR_CHARGE, "r") as f:
        cur = int(f.read().strip())
    return cur / FULL

def status():
    with open(AC_ON, "r") as f:
        status = f.read().strip()
        return (status != "Discharging", status == "Full")

data = {
        'charging' : {
            'times' : [],
            'levels' : [],
            'drains' : []
            },
        'battery' : {
            'times' : [],
            'levels' : [],
            'drains' : []
            }
        }

pcharging, pfull = status()
ptime = int(time.time())

while True:
    charging, full = status()

    if full:
        if os.path.isfile(STAT):
            os.remove(STAT)
    else:
        d = data['charging'] if charging else data['battery']
        times = d['times']
        levels = d['levels']
        drains = d['drains']

        ctime = int(time.time())
        if pcharging != charging or (ctime - ptime) > INT * 1.5:
            times.clear()
            levels.clear()

        if len(times) < FLUSH:
            if not times:
                times.append(0)
            else:
                times.append(times[-1] + INT)
        else:
            levels.pop(0)
        levels.append(level())

        if len(levels) <= MIN:
            drain = MCGRAD if charging else MGRAD
            inter = level()
        else:
            A = np.vstack([np.array(times), np.ones(len(times))]).T
            drain, inter = np.linalg.lstsq(A, levels)[0]

        target = 1 if charging else LOW
        eta = (target - inter) / drain
        eta = round(eta - times[-1])

        m, s = divmod(eta, 60)
        h, m = divmod(m, 60)

        h = int(h)
        m = int(m)

        drains.append(drain)
        if len(drains) == FLUSH:
            f = MC_HIST if charging else M_HIST
            with open(f, "a") as f:
                f.write("{}\n".format(np.mean(drains)))
            drains.clear()

        with open(STAT, "w") as f:
            f.write(f'{h:02}:{m:02}')

    pcharging, pfull = charging, full
    ptime = int(time.time())
    time.sleep(INT)
