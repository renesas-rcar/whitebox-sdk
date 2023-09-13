#!/bin/bash -eu

BASE_DIR=$(cd `dirname $0` && pwd)
BUILD_PATTERN=-1

# Build patterns: G4MH, CR52, CA55
BUILD_PATTERNS=( "dummy" "dummy" "dummy" # -0(dummy)
    "Trampoline" "Trampoline" "Linux" # -1
    "SafeG-Auto" "Trampoline" "Linux" # -2
    "Trampoline" "Zephyr"     "Linux" # -3
    "SafeG-Auto" "Zephyr"     "Linux" # -4
)
BUILD_PATTERS_NUM=$((${#BUILD_PATTERNS[@]} / 3  -1))

Usage() {
    echo "Usage:"
    echo "    $0 board [option]"
    echo "board:"
    echo "    - spider: for S4 Spider"
    echo "    - s4sk: for S4 Starter Kit"
    echo "option:"
    for key in `seq 1 ${BUILD_PATTERS_NUM}`; do
        echo -ne "    -${key}: "
        echo -ne "G4MH=${BUILD_PATTERNS[$((3*$key+0))]}\t"
        echo -ne "CR52=${BUILD_PATTERNS[$((3*$key+1))]}\t"
        echo -e "CA55=${BUILD_PATTERNS[$((3*$key+2))]}"
    done
    echo "    -h: Show this usage"
}

build_all() {
    for board in spider s4sk ; do
        $0 $board -1
        mv ${BASE_DIR}/realtime_cpu/deploy ${BASE_DIR}/deploy/cr52_trampoline_deploy
        mv ${BASE_DIR}/mcu/deploy ${BASE_DIR}/deploy/g4mh_trampoline_deploy
        mv ${BASE_DIR}/mcu/trampoline ${BASE_DIR}/deploy/g4mh_trampoline_deploy/trampoline_bench

        ${BASE_DIR}/realtime_cpu/build_zephyr.sh $board -c
        mv ${BASE_DIR}/realtime_cpu/deploy ${BASE_DIR}/deploy/cr52_zephyr_deploy

        ${BASE_DIR}/mcu/build_safegauto.sh -c
        mv ${BASE_DIR}/mcu/deploy ${BASE_DIR}/deploy/g4mh_safegauto_deploy
        mv ${BASE_DIR}/mcu/safeg-auto-bench ${BASE_DIR}/deploy/g4mh_safegauto_deploy/safeg-auto_bench

        mv ${BASE_DIR}/deploy ${BASE_DIR}/deploy_$board
    done
    exit
}

# Board selection is required
if [[ $# < 1 ]] ; then
    echo -e "\e[31mERROR: Please select a board to build\e[m"
    Usage; exit
fi
if [[ "$1" == "-h" ]]; then
    Usage; exit
elif [[ "$1" == "all" ]]; then
    build_all; exit
elif [[ "$1" != "spider" ]] && [[ "$1" != "s4sk" ]]; then
    echo -e "\e[31mERROR: Please "input" correct board name: spider or s4sk\e[m"
    Usage; exit
fi

# Without option, pattern 1 is selected by default.
if [[ $# < 2 ]]; then
    $0 $1 -1
    exit
elif [[ $# > 2 ]]; then # option can be used only one
    Usage; exit
fi

# Proc arguments
OPTIND=2
while getopts "1234h" OPT
do
  case $OPT in
     [0-9]) BUILD_PATTERN=$OPT;;
     h) Usage; exit;;
     *) echo -e "\e[31mERROR: Unsupported option\e[m"; Usage; exit;;
  esac
done
G4MH=${BUILD_PATTERNS[$((3*${BUILD_PATTERN}+0))]}
CR52=${BUILD_PATTERNS[$((3*${BUILD_PATTERN}+1))]}
CA55=${BUILD_PATTERNS[$((3*${BUILD_PATTERN}+2))]}

# Build G4MH
cd ${BASE_DIR}/mcu
case $G4MH in
    "Trampoline") ./build_trampoline.sh -c;;
    "SafeG-Auto") ./build_safegauto.sh -c;;
esac

# Build CR52
cd ${BASE_DIR}/realtime_cpu
case $CR52 in
    "Trampoline") ./build_trampoline.sh $1 -c;;
    "Zephyr")     ./build_zephyr.sh $1 -c;;
esac

# Build CA55
cd ${BASE_DIR}/application_cpu
case $CA55 in
    "Linux") ./build_xenhypervisor.sh $1 -c;;
esac

# deploy images
cd ${BASE_DIR}
mkdir -p deploy
cp mcu/deploy/g4mh.srec deploy/App_CDD_ICCOM_S4_Sample_G4MH.srec
cp realtime_cpu/deploy/cr52.srec deploy/App_CDD_ICCOM_S4_Sample_CR52.srec
cp application_cpu/work/full.img.gz deploy/
cp application_cpu/work/yocto/build-domd/tmp/deploy/images/${1}/bl31-${1}.srec deploy/
cp application_cpu/work/yocto/build-domd/tmp/deploy/images/${1}/tee-${1}.srec deploy/
cp application_cpu/work/yocto/build-domd/tmp/deploy/images/${1}/u-boot-elf-${1}.srec deploy/

ls -l deploy

