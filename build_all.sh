#!/bin/bash -eu

SCRIPT_DIR=$(cd `dirname $0` && pwd)
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
    while getopts "h" OPT
    do
        case $OPT in
            h) Usage; exit;;
            *) echo Unsupported option; Usage; exit;;
        esac
    done

    if [[ $# < 1 ]] ; then
        echo -e "\e[31mERROR: Please select a board to build\e[m"
        Usage; exit
    fi

    for board in ${BOARD_LIST[*]}; do
        if [[ "$board" == "$1" ]]; then
            TARGET_BOARD=$1
            shift 1
            break
        fi
    done
    if [[ -z ${TARGET_BOARD} ]]; then
        Usage; exit;
    fi
}

#================================================
# Main func
#================================================
proc_args $@

CLEAN_BUILD_FLAG=true ${SCRIPT_DIR}/build_h3.sh
CLEAN_BUILD_FLAG=true ${SCRIPT_DIR}/build_s4.sh $TARGET_BOARD

# deploy
DEPLOY_DIR=${SCRIPT_DIR}/deploy_${TARGET_BOARD}
rm -rf ${DEPLOY_DIR} && mkdir -p ${DEPLOY_DIR}
cp -r -t ${DEPLOY_DIR} \
    ${SCRIPT_DIR}/work/h3_build/*img.gz \
    ${SCRIPT_DIR}/work/h3_build/h3_ipl \
    ${SCRIPT_DIR}/work/s4_build/*img.gz \
    ${SCRIPT_DIR}/work/s4_build/s4_ipl \

ls -l ${DEPLOY_DIR}

