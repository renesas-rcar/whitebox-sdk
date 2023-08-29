#!/bin/bash -eu

BASE_DIR=$(cd `dirname $0` && pwd)

Usage() {
    echo "Usage:"
    echo "    $0 board [option]"
    echo "board:"
    echo "    - spider: for S4 Spider"
    echo "    - s4sk: for S4 Starter Kit"
    echo "option:"
    echo "    -h: Show this usage"
}

# Without option, pattern 1 is selected by default.
if [[ $# < 1 ]]; then
    echo -e "\e[31mERROR: Please "input" correct board name: spider or s4sk\e[m"
    Usage; exit
fi

if [[ "$1" == "-h" ]]; then
    Usage; exit
elif [[ "$1" != "spider" ]] && [[ "$1" != "s4sk" ]]; then
    echo -e "\e[31mERROR: Please "input" correct board name: spider or s4sk\e[m"
    Usage; exit
fi

ICUMX_LOADER_PATH=$(find ${BASE_DIR}/tool -name "*ICUMX_Loader_and_Flashwriter_Package_for_R-Car_S4_Starter_Kit_SDKv*.zip")
if [ "${ICUMX_LOADER_PATH}" == "" ]; then
  echo -e "\e[31mERROR: ICUMX loader file (zip) not found in tool directory.\e[m"
  exit
fi

# deploy images
cd ${BASE_DIR}
rm -rf deploy
mkdir -p deploy

# Build G4MH
cd ${BASE_DIR}/mcu
./build_trampoline.sh $1 -c
mv ${BASE_DIR}/mcu/deploy ${BASE_DIR}/deploy/g4mh_trampoline_deploy
./build_safegauto.sh -c
mv ${BASE_DIR}/mcu/deploy ${BASE_DIR}/deploy/g4mh_safegauto_deploy

# Build CR52
cd ${BASE_DIR}/realtime_cpu
./build_trampoline.sh $1 -c
mv ${BASE_DIR}/realtime_cpu/deploy ${BASE_DIR}/deploy/cr52_trampoline_deploy
./build_zephyr.sh $1 -c
mv ${BASE_DIR}/realtime_cpu/deploy ${BASE_DIR}/deploy/cr52_zephyr_deploy

# Build CA55
cd ${BASE_DIR}/application_cpu
./build_xenhypervisor.sh $1 -c
cd ${BASE_DIR}/
cp application_cpu/work/*full.img.gz deploy/
cp application_cpu/work/yocto/build-domd/tmp/deploy/images/${1}/bl31-${1}.srec deploy/
cp application_cpu/work/yocto/build-domd/tmp/deploy/images/${1}/tee-${1}.srec deploy/
cp application_cpu/work/yocto/build-domd/tmp/deploy/images/${1}/u-boot-elf-${1}.srec deploy/

ls -l deploy

cd tool
./setup_ipl.sh $1

