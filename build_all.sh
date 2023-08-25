#!/bin/bash

SCRIPT_DIR=$(cd `dirname $0` && pwd)
DEPLOY_DIR=${SCRIPT_DIR}/deploy

Usage () {
    echo "Usage:"
    echo "    $0 spider|s4sk"
}

if [[ $# -ne 1 ]]; then
    Usage; exit -1
fi

if [[ "$1" == "spider" ]]; then
    CLEAN_BUILD_FLAG=true ${SCRIPT_DIR}/build_s4.sh
elif [[ "$1" == "s4sk" ]]; then
    CLEAN_BUILD_FLAG=true ${SCRIPT_DIR}/build_s4sk.sh
else
    Usage; exit -1;
fi

CLEAN_BUILD_FLAG=true ${SCRIPT_DIR}/build_h3.sh

# deploy
rm -rf ${DEPLOY_DIR} && mkdir -p ${DEPLOY_DIR}
cp -r -t ${DEPLOY_DIR} \
    ${SCRIPT_DIR}/work/h3_build/*img.gz \
    ${SCRIPT_DIR}/work/h3_build/h3_ipl \
    ${SCRIPT_DIR}/work/s4_build/*img.gz \
    ${SCRIPT_DIR}/work/s4_build/s4_ipl \

ls -l ${DEPLOY_DIR}

