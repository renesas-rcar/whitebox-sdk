#!/bin/bash

IS_CAN1_EXIST=false
ip -br a show can1 >/dev/null 2>&1
if [[ $? -eq 0 ]] ;then
    IS_CAN1_EXIST=true
fi

SCRIPT_DIR=$(cd `dirname $0` && pwd)
cd $SCRIPT_DIR

pids=()

cd $SCRIPT_DIR/grafana
./bin/grafana-server > /dev/null 2>&1 &
pids+=($!)
cd $SCRIPT_DIR/prometheus
./prometheus > /dev/null 2>&1 &
pids+=($!)
cd $SCRIPT_DIR/node_exporter
./node_exporter > /dev/null 2>&1 &
pids+=($!)
cd $SCRIPT_DIR
# python3 ./api-server.py > /dev/null 2>&1 &
python3 ./api-server.py & # for debug
pids+=($!)

# ps
TTY_SIZE=80x16
TTY_SIZE=80x10
asciinema stream --serve 0.0.0.0:8000 \
    -c "while :; do python3 -m can.viewer -i socketcan --fd -c can0; done"  \
    --tty-size=$TTY_SIZE --headless &
pids+=($!)

if [[ "$IS_CAN1_EXIST" == "true" ]]; then
    asciinema stream --serve 0.0.0.0:8001 \
        -c "while :; do python3 -m can.viewer -i socketcan --fd -c can1; done"  \
        --tty-size=$TTY_SIZE --headless &
    pids+=($!)
fi

end_process () {
    for pid in ${pids[@]}; do
        kill $pid
    done
}
# pids+=($!)
echo "To exit this app, press the CTRL+C."

trap "end_process" SIGINT

wait

# echo;
# ps


