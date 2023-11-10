#!/bin/bash -eu

BASE_DIR=$(cd `dirname $0` && pwd)

Usage() {
    echo "Usage:"
    echo "    $0 board [option] "
    echo "board:"
    echo "    - spider: for S4 Spider"
    echo "    - s4sk: for S4 Starter Kit"
    echo "option:"
    echo "    -h: Show this usage"
}

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

# IPL image deployment and copying
ICUMX_LOADER_PATH=$(find ${BASE_DIR} -name "*ICUMX_Loader_and_Flashwriter_Package_for_R-Car_S4_Starter_Kit_SDKv*.zip")
if [ "${ICUMX_LOADER_PATH}" == "" ]; then
    echo -e "\e[31mERROR: ICUMX Loader file(zip) is not found.\e[m"
    exit -2
elif [ $(echo "${ICUMX_LOADER_PATH}" | wc -l) -ne 1 ]; then
    echo -e "\e[31mERROR: Multiple ICUMX Loader files(zip) are found.\e[m"
    echo -e "\e[31mERROR: Please copy only one file into tool directory\e[m"
    exit -2
fi

cd $BASE_DIR
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

