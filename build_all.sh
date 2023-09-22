#!/bin/bash -eu

SCRIPT_DIR=$(cd `dirname $0` && pwd)
DEPLOY_DIR=${SCRIPT_DIR}/deploy
TARGET_BOARD=""
BOARD_LIST=("spider" "s4sk")

#================================================
# Usage
#================================================
Usage() {
    echo "Usage:"
    echo "    $0 board [option]"
    echo "board:"
    for i in ${BOARD_LIST[@]}; do echo "  - $i"; done
    echo "option:"
    echo "    -h: Show this usage"
}

#================================================
# Check commandline args
#================================================
proc_args () {
    for board in ${BOARD_LIST[*]}; do
        if [[ "$board" == "$1" ]]; then
            TARGET_BOARD=$1
            shift 1
        fi
    done
    if [[ -z ${TARGET_BOARD} ]]; then
        Usage; exit;
    fi

    while getopts "h" OPT
    do
        case $OPT in
            h) Usage; exit;;
            *) echo Unsupported option; Usage; exit;;
        esac
            echo $OPT
    done
}

#================================================
# Main func
#================================================
proc_args $@

CLEAN_BUILD_FLAG=true ${SCRIPT_DIR}/build_h3.sh
CLEAN_BUILD_FLAG=true ${SCRIPT_DIR}/build_s4.sh $TARGET_BOARD

# deploy
rm -rf ${DEPLOY_DIR} && mkdir -p ${DEPLOY_DIR}
cp -r -t ${DEPLOY_DIR} \
    ${SCRIPT_DIR}/work/h3_build/*img.gz \
    ${SCRIPT_DIR}/work/h3_build/h3_ipl \
    ${SCRIPT_DIR}/work/s4_build/*img.gz \
    ${SCRIPT_DIR}/work/s4_build/s4_ipl \

ls -l ${DEPLOY_DIR}

