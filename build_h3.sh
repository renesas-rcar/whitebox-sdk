#!/bin/bash -eu

SCRIPT_DIR=$(cd `dirname $0` && pwd)
WORK_DIR=${SCRIPT_DIR}/work/h3_build

# Other variables
SOC=h3
HOSTPC_PREFIX=""

# moulin configs
MACHINE=h3ulcb
USING_EXT_BOARD=ccpf
ENABLE_DEMO=yes
ENABLE_MMP=yes
ENABLE_DEMO_HOST=no

# Usage
Usage() {
    echo "Usage:"
    echo "    $0 [options]"
    echo "options:"
    echo "    -c: Enable clean build flag"
    echo "    -e: Build with Starter Kit + CCPF-SK(Default is enabled)"
    echo "    -s: Build with Starter Kit only(Default is disabled)"
    echo "    -h: Show this usage"
    echo "options(development purpose only. not supported and tested)"
    echo "    -m: Use M3SK instead of H3SK"
    echo "    -n: Build without GFX/MMP evaluation package"
    echo "    -p: Build as Host PC, which is used instead of Windows PC."
}

# Proc arguments
while getopts "ceshmnp" OPT
do
  case $OPT in
    c) CLEAN_BUILD_FLAG=true;;
    e) USING_EXT_BOARD=ccpf;;
    s) USING_EXT_BOARD=no;;
    m) MACHINE=m3ulcb; SOC=m3 ;;
    n) ENABLE_MMP=no;;
    p) HOSTPC_PREFIX="hostpc_"; ENABLE_DEMO_HOST=yes ;;
    h) Usage; exit;;
    *) echo Unsupported option; Usage; exit;;
  esac
done
WORK_DIR=${SCRIPT_DIR}/work/${HOSTPC_PREFIX}${SOC}_build;

# Move to working direcotry
if [[ "${CLEAN_BUILD_FLAG:-false}" == "true" ]]; then
    rm -rf ${WORK_DIR}
fi
mkdir -p ${WORK_DIR}
cd ${WORK_DIR}

# Check propieray package
if [[ ${ENABLE_MMP} == "yes" ]]; then
    LIB=R-Car_Gen3_Series_Evaluation_Software_Package_for_Linux-20220121.zip
    DRV=R-Car_Gen3_Series_Evaluation_Software_Package_of_Linux_Drivers-20220121.zip
    err_msg () {
        echo "ERROR: Evaluation package is not found:"
        echo "  - ${SCRIPT_DIR}/proprietary/${LIB}"
        echo "  - ${SCRIPT_DIR}/proprietary/${DRV}"
        echo "Please download above files referencing elinux wiki:"
        echo "  - https://elinux.org/R-Car/Boards/Yocto-Gen3/v5.9.0#Required_packages"
    }
    if [[ ! -e "${SCRIPT_DIR}/proprietary/${LIB}" ]]; then
        err_msg; exit -1
    fi
    if [[ ! -e "${SCRIPT_DIR}/proprietary/${DRV}" ]]; then
        err_msg; exit -1
    fi
fi

moulin ../../rcar-gen3-ulcb.yaml \
    --MACHINE=${MACHINE} \
    --USING_EXT_BOARD=${USING_EXT_BOARD} \
    --ENABLE_DEMO=${ENABLE_DEMO} \
    --ENABLE_MMP=${ENABLE_MMP} \
    --ENABLE_DEMO_HOST=${ENABLE_DEMO_HOST}
ninja

# copy required files
EXT_BOARD_PREFIX=""
if [[ $USING_EXT_BOARD == "ccpf" ]]; then
    EXT_BOARD_PREFIX=-ccpf
fi
BUILD_TYPE=mmp
if [[ ${ENABLE_MMP} == "no" ]]; then
    BUILD_TYPE=bsp-wayland
fi

cd ${WORK_DIR}/yocto/build-${MACHINE}${EXT_BOARD_PREFIX}-${BUILD_TYPE}/tmp/deploy/images/${MACHINE}/
rm -rf ${WORK_DIR}/${SOC}_ipl
mkdir -p ${WORK_DIR}/${SOC}_ipl
cp -r -t ${WORK_DIR}/${SOC}_ipl ./*.srec ./renesas-bsp-rom-writer_64bit
# cp -t ${WORK_DIR} core-image-weston-${MACHINE}.wic.* # for sdcard boot
cp core-image-weston-${MACHINE}.wic.gz ${WORK_DIR}/gen3.demo.full.img.gz

