#!/bin/bash

SCRIPT_DIR=$(cd `dirname $0` && pwd)
DEPLOY_DIR=${SCRIPT_DIR}/deploy

CLEAN_BUILD_FLAG=true ${SCRIPT_DIR}/build_h3.sh
CLEAN_BUILD_FLAG=true ${SCRIPT_DIR}/build_s4.sh

# deploy
rm -rf ${DEPLOY_DIR} && mkdir -p ${DEPLOY_DIR}
cp -r -t ${DEPLOY_DIR} \
    ${SCRIPT_DIR}/work/h3_build/*img.gz \
    ${SCRIPT_DIR}/work/h3_build/h3_ipl \
    ${SCRIPT_DIR}/work/s4_build/*img.gz \
    ${SCRIPT_DIR}/work/s4_build/s4_ipl \

ls -l ${DEPLOY_DIR}

