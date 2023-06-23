#!/bin/bash -eu

SCRIPT_DIR=$(cd `dirname $0` && pwd)
export ZEPHYR_DIR=${SCRIPT_DIR}/zephyrproject
ZEPHYR_SDK_PATH=${SCRIPT_DIR}/zephyr-sdk-0.15.2

CLEAN_BUILD_FLAG=false
Usage() {
    echo "Usage:"
    echo "    $0 [board] [option]"
    echo "board:"
    echo "    - spider: R-Car S4 Spider board"
    echo "    - s4sk: R-Car S4 Starter Kit"
    echo "option:"
    echo "    -c: Clean build flag(Defualt is disable)"
}
# Proc arguments
OPTIND=2
while getopts "ch" OPT
do
    case $OPT in
        c) CLEAN_BUILD_FLAG=true;;
        h) Usage; exit;;
        *) echo Unsupported option; Usage; exit;;
    esac
done

if [[ ! -e ${ZEPHYR_DIR} || "$CLEAN_BUILD_FLAG" == "true" ]]; then
    rm -rf ${ZEPHYR_DIR}
    mkdir -p ${ZEPHYR_DIR}
fi

# Board argument
if [ "$1" == "s4sk" ]; then BOARD="s4sk"
elif [ "$1" == "spider" ]; then BOARD="spider"
else echo "ERROR: Please specify a board name: spider or s4sk"; exit 1
fi	

# Setup SDK
cd ${SCRIPT_DIR}
if [ ! -e "${ZEPHYR_SDK_PATH}" ]; then
    wget -c https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.15.2/zephyr-sdk-0.15.2_linux-x86_64.tar.gz
    tar xvf zephyr-sdk-0.15.2_linux-x86_64.tar.gz
    rm -f zephyr-sdk-0.15.2_linux-x86_64.tar.gz
fi
cd zephyr-sdk-0.15.2
./setup.sh -c

# Setup python env
python3 -m venv ${ZEPHYR_DIR}/.venv
source ${ZEPHYR_DIR}/.venv/bin/activate
pip install wheel
pip install west

# Setup source code
cd ${ZEPHYR_DIR}
if [ ! -e "./.west/config" ]; then
    west init -m  https://github.com/iotbzh/zephyr.git --manifest-rev 2022-12-20-s4sk ${ZEPHYR_DIR}
fi
west update
west zephyr-export
pip install -r ${ZEPHYR_DIR}/zephyr/scripts/requirements.txt

# Build
cd ${ZEPHYR_DIR}/zephyr
west build -p always -b rcar_${BOARD}_cr52 samples/basic/blinky
${ZEPHYR_SDK_PATH}/arm-zephyr-eabi/bin/arm-zephyr-eabi-objcopy --adjust-vma 0xe2100000 -O srec --srec-forceS3 \
    ${ZEPHYR_DIR}/zephyr/build/zephyr/zephyr.elf build/zephyr/zephyr.srec

# deploy
mkdir -p ${SCRIPT_DIR}/deploy
cp -f ${ZEPHYR_DIR}/zephyr/build/zephyr/zephyr.srec ${SCRIPT_DIR}/deploy/cr52.srec

