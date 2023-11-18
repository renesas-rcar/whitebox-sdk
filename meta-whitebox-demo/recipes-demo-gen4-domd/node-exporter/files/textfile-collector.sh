#!/bin/bash

TEXTFILE_DIR="/var/lib/node_exporter/textfile_collector"
mkdir -p $TEXTFILE_DIR

while :; do
    VALUE=0
    if [[ "$(systemctl status snort-tsn0 | grep Active | grep running)" != "" ]]; then
        VALUE=1
    fi
    METRICS_NAME="snort_tsn0_service_status"

    echo "${METRICS_NAME} ${VALUE}" > ${TEXTFILE_DIR}/${METRICS_NAME}.prom.$$
    mv ${TEXTFILE_DIR}/${METRICS_NAME}.prom.$$ ${TEXTFILE_DIR}/${METRICS_NAME}.prom

    sleep 1s
done

