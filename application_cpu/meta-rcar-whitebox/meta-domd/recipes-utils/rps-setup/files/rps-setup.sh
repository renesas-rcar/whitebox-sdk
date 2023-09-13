#!/bin/bash

TSN_DEV_LIST=$(ip -br a | grep tsn | awk '{print $1}')
RMON_DEV_LIST=$(ip -br a | grep rmon | awk '{print $1}')
CPU_NUM=$(cat /proc/cpuinfo  | grep processor | wc -l)

# CPU_MASK without core0
# if CPU_NUM=4, 0b1111 -> 0xf
# if CPU_NUM=4 + CPU0 is disabled, 0b1110 -> 0xe
CPU_MASK=$(printf '%x\n' $((2**${CPU_NUM}-1-1)) )

for TSN_DEV in ${TSN_DEV_LIST}; do
    echo ${CPU_MASK} > /sys/class/net/${TSN_DEV}/queues/rx-0/rps_cpus
done

for RMON_DEV in ${RMON_DEV_LIST}; do
    echo ${CPU_MASK} > /sys/class/net/${RMON_DEV}/queues/rx-0/rps_cpus
done

