#!/bin/bash

SCRIPT_DIR=$(cd `dirname $0` && pwd)
cd $SCRIPT_DIR

./setup_ca55.sh
./setup_cr52.sh
./setup_g4mh.sh

