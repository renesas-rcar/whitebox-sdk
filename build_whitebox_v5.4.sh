#!/bin/bash -eu

BASE_DIR=$(cd `dirname $0` && pwd)
TARGET_BOARD=""

Usage() {
    echo "Usage:"
    echo "    $0 board [option]"
    echo "board:"
    echo "    - spider: for S4 Spider"
    echo "    - s4sk: for S4 Starter Kit"
    echo "option:"
    echo "    -h: Show this usage"
}

print_err() {
    for arr in "$@"; do
        echo -e "\e[31m$arr\e[m"
    done
}

for arr in $@; do
    case "$arr" in
        s4sk  ) TARGET_BOARD+=s4sk ;;
        spider) TARGET_BOARD+=spider ;;
        all   ) TARGET_BOARD+=all;;
        -h    ) Usage; exit ;;
    esac
done
if [[ "$TARGET_BOARD" == "all" ]]; then
    $0 s4sk && mv deploy{,_s4sk}
    $0 spider && mv deploy{,_spider}
    exit
fi
if [[ "$TARGET_BOARD" != "spider" ]] && [[ "$TARGET_BOARD" != "s4sk" ]]; then
    print_err "Please \"input\" correct board name: spider or s4sk"
    Usage; exit
fi

ICUMX_LOADER_PATH=$(find ${BASE_DIR}/tool -name "*ICUMX_Loader_and_Flashwriter_Package_for_R-Car_S4_Starter_Kit_SDKv*.zip")
if [ "${ICUMX_LOADER_PATH}" == "" ]; then
    print_err "ERROR: ICUMX Loader file(zip) is not found."
    print_err "    This is not used for building, but it's required for executing Whitebox SDK."
    print_err "    1. Please donwload "ICUMX_Loader_and_Flashwriter_Package_for_R-Car_S4_Starter_Kit_SDKv3.16.1" or later from following: \e[m"
    print_err "    https://www.renesas.com/products/automotive-products/automotive-system-chips-socs/y-ask-rcar-s4-1000base-t-r-car-s4-starter-kit#download"
    print_err "    2. Copy downloaded file into tool directory."
    print_err "    cp <path to downloaded file> -t ./tool"
    exit
elif [ $(echo "${ICUMX_LOADER_PATH}" | wc -l) -ne 1 ]; then
    print_err "ERROR: Multiple ICUMX Loader files(zip) are found."
    for item in ${ICUMX_LOADER_PATH}; do print_err "    - $item"; done
    print_err "    Please copy only one zip file into tool directory"
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

# Prepare IPL
cd $BASE_DIR/tool
unzip -qo ${ICUMX_LOADER_PATH}
cp -f ${ICUMX_LOADER_PATH%.zip}/*.srec ${ICUMX_LOADER_PATH%.zip}/*.mot -t ../deploy

# Copy macros and shells to match board
cp IPL/* ../deploy/
if [ "$1" == "s4sk" ]; then
    rm -rf ../deploy/Flash_Bootloader_Spider.ttl
elif [ "$1" == "spider" ];  then
    rm -rf ../deploy/Flash_Bootloader_S4SK.ttl
fi
# Changed CR52 memory placement to 0x40040000
sed -i 's/S315EB23695000000000000010E2000000000000000031/S315EB23695000000000000004400000000000000000DF/g' ../deploy/cert_header_sa9.srec

