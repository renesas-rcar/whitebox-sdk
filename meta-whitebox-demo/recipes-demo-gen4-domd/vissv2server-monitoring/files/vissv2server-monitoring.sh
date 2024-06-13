#!/bin/bash

while :; do
    LOG=$(journalctl -u vissv2server --since="$(date -d '10 second ago' '+%Y-%m-%d %H:%M:%S')" | grep Vehicle.)
    if [[ "${LOG}" == "" ]]; then
        echo -ne Restart the server:; date
        systemctl restart vissv2server
    fi
    CHECK_LOG=$(dmesg | grep "tsn1: Link is Up" | tail -1)
    if [[ "${CHECK_LOG}" != "${LAST_TSN1_UP_LOG}" ]]; then
        if [[ "$(echo $CHECK_LOG | grep 100M)" != "" ]]; then
            echo -ne Refresh TSN1 interface:; date
            ifconfig tsn1 down; sleep 1s
            ifconfig tsn1 up; sleep 1s
        fi
    fi
    sleep 5s
done

