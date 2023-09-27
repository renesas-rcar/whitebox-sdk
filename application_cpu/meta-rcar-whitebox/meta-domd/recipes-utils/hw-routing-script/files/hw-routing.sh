#!/bin/bash

if [[ "$1" == "on" ]]; then
    echo 1 > /sys/devices/platform/soc/e68c0000.ethernet/l3_offload
elif [[ "$1" == "off" ]]; then
    echo 0 > /sys/devices/platform/soc/e68c0000.ethernet/l3_offload
else
    echo "Usage: $0 on|off"; exit -1
fi
