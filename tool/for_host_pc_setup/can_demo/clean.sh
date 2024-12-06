#!/bin/bash

SCRIPT_DIR=$(cd `dirname $0` && pwd)
cd $SCRIPT_DIR

if [[ "`basename $SCRIPT_DIR`" != "can-demo-sample-app" ]]; then
    rm -rf grafana* node_exporter* prometheus*  node-exporter-full.json
else
    echo This directory is working directory,
    echo if you want to cleanup the dirctory to distribute it, 
    echo please copy this directory to can-demo-sample-app_xxxxxxxx.
    echo Then, rerun this script into new directory
fi

