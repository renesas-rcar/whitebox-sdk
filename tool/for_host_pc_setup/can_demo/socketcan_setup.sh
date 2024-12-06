#!/bin/bash

CAN_DEV_LIST=("can0")
ip -br a show can1 >/dev/null 2>&1
if [[ $? -eq 0 ]] ;then
    CAN_DEV_LIST+=("can1")
fi

set -x
for CAN_DEV in "${CAN_DEV_LIST[@]}"; do
    sudo ip link set $CAN_DEV down; sudo ip link set $CAN_DEV up type can bitrate 500000 restart-ms 100 dbitrate 2000000 fd on
done
