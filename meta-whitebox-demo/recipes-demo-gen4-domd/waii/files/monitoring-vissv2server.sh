#!/bin/bash

while :; do
    timeout 2 wget -O- localhost:8888 > /dev/null
    if [[ $? -ne 0 ]]; then
        echo Error
        systemctl restart vissv2server
    else
        echo OK
    fi
    sleep 1
done


