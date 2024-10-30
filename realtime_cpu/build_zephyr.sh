#!/bin/bash -eu

SCRIPT_DIR=$(cd `dirname $0` && pwd)
export ZEPHYR_DIR=${SCRIPT_DIR}/zephyrproject
ZEPHYR_SDK_PATH=${SCRIPT_DIR}/zephyr-sdk-0.15.2
ZEPHYR_PATCH=${SCRIPT_DIR}/patchset_zephyr

CLEAN_BUILD_FLAG=false
ORIGINAL_ADDR_USED_FLAG=false
Usage() {
    echo "Usage:"
    echo "    $0 board [option]"
    echo "board:"
    echo "    - spider: R-Car S4 Spider board"
    echo "    - s4sk: R-Car S4 Starter Kit"
    echo "option:"
    echo "    -c: Clean build flag(Defualt is disable)"
    echo "    -h: Show this usage"
    echo "    -o: Using original address"
    echo "        Whitebox uses 0x40040000 to place cr52 program but"
    echo "        but original S4 SDK uses 0xe2100000"
    echo "        If this option is specified, 0xe210000 is used."
}
# Proc arguments
OPTIND=2
while getopts "cho" OPT
do
    case $OPT in
        c) CLEAN_BUILD_FLAG=true;;
        h) Usage; exit;;
        o) ORIGINAL_ADDR_USED_FLAG=true;;
        *) echo -e "\e[31mERROR: Unsupported option\e[m"; Usage; exit;;
    esac
done

# Board argument
if [[ $# < 1 ]]; then
    echo -e "\e[31mERROR: Please select a board to build\e[m"
    Usage; exit
fi

if [ "$1" == "s4sk" ]; then BOARD="s4sk"
elif [ "$1" == "spider" ]; then BOARD="spider"
else echo -e "\e[31mERROR: Please "input" correct board name: spider or s4sk\e[m"; Usage; exit
fi

ADJUST_VMA_OPT="--adjust-vma=0x40040000" # For WhiteboxSDK env
if [[ "${ORIGINAL_ADDR_USED_FLAG}" == "true" ]]; then
    ADJUST_VMA_OPT="--adjust-vma=0xe2100000" # For original env
fi

if [[ "$CLEAN_BUILD_FLAG" == "true" ]]; then
    rm -rf ${ZEPHYR_DIR}
fi
mkdir -p ${ZEPHYR_DIR}

# Setup SDK
cd ${SCRIPT_DIR}
if [ ! -e "${ZEPHYR_SDK_PATH}" ]; then
    # Minimal SDK
    wget -c https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.15.2/zephyr-sdk-0.15.2_linux-x86_64_minimal.tar.gz
    tar xf zephyr-sdk-0.15.2_linux-x86_64_minimal.tar.gz
    # toolchain
    wget -c https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.15.2/toolchain_linux-x86_64_arm-zephyr-eabi.tar.gz
    tar xf toolchain_linux-x86_64_arm-zephyr-eabi.tar.gz -C zephyr-sdk-0.15.2
fi

cd zephyr-sdk-0.15.2
./setup.sh -c

# Setup python env
python3 -m venv ${ZEPHYR_SDK_PATH}/.venv
source ${ZEPHYR_SDK_PATH}/.venv/bin/activate
pip install wheel
pip install west -U
CLONE_OPT_FLAG=""
if [[ "$(west help init | grep CLONE_OPT)" != "" ]]; then
    CLONE_OPT_FLAG=" -o--depth=1 "
fi

# Setup source code
if [[ ! -e "${ZEPHYR_DIR}/zephyr" || "$CLEAN_BUILD_FLAG" == "true" ]]; then
    cd ${ZEPHYR_DIR}
    if [ ! -e "./.west/config" ]; then
        west init -m  https://github.com/iotbzh/zephyr.git --manifest-rev 2022-12-20-s4sk ${ZEPHYR_DIR} ${CLONE_OPT_FLAG}
    fi
    cd ${ZEPHYR_DIR}/zephyr
    git am ${ZEPHYR_PATCH}/*.patch
    west update -n
    west zephyr-export
    pip install docutils==0.18.1 # Avoid error when installing sphinx
    pip install -r ${ZEPHYR_DIR}/zephyr/scripts/requirements.txt
fi

# Build
cd ${ZEPHYR_DIR}/zephyr
west build -p always -b rcar_${BOARD}_cr52 samples/basic/blinky
${ZEPHYR_SDK_PATH}/arm-zephyr-eabi/bin/arm-zephyr-eabi-objcopy ${ADJUST_VMA_OPT} -O srec --srec-forceS3 \
    ${ZEPHYR_DIR}/zephyr/build/zephyr/zephyr.elf build/zephyr/zephyr.srec

# deploy
mkdir -p ${SCRIPT_DIR}/deploy
cp -f ${ZEPHYR_DIR}/zephyr/build/zephyr/zephyr.srec ${SCRIPT_DIR}/deploy/cr52.srec

# build benchmark
## Setup source code
if [[ ! -e "${ZEPHYR_DIR}/zephyr/samples/basic/benchmark/src/dhrystone" || "$CLEAN_BUILD_FLAG" == "true" ]]; then
    ### Dhrystone
    cd ${ZEPHYR_DIR}/zephyr/samples/basic/benchmark/src
    rm -rf ./dhrystone
    wget -c https://fossies.org/linux/privat/old/dhrystone-2.1.tar.gz
    mkdir -p ./dhrystone && tar xf dhrystone-2.1.tar.gz -C ./dhrystone
    cp ./dhrystone/dhry_1.c{,.org}
    cd ./dhrystone
    patch -p1 <  ${ZEPHYR_PATCH}/dhry_1.c.diff
    ### Coremark
    if [ ! -e ${ZEPHYR_DIR}/zephyr/samples/basic/benchmark/src/coremark ]; then
        git clone https://github.com/eembc/coremark ${ZEPHYR_DIR}/zephyr/samples/basic/benchmark/src/coremark
    fi
    cd ${ZEPHYR_DIR}/zephyr/samples/basic/benchmark/src/coremark
    git reset --hard d5fad6bd094899101a4e5fd53af7298160ced6ab ; git clean -df
    git apply ${ZEPHYR_PATCH}/coremark.diff
fi

## Build
cd ${ZEPHYR_DIR}/zephyr
west build -p always -b rcar_${BOARD}_cr52 samples/basic/benchmark
${ZEPHYR_SDK_PATH}/arm-zephyr-eabi/bin/arm-zephyr-eabi-objcopy ${ADJUST_VMA_OPT} -O srec --srec-forceS3 \
    ${ZEPHYR_DIR}/zephyr/build/zephyr/zephyr.elf build/zephyr/zephyr.srec

# deploy
mkdir -p ${SCRIPT_DIR}/deploy
cp -f ${ZEPHYR_DIR}/zephyr/build/zephyr/zephyr.srec ${SCRIPT_DIR}/deploy/cr52_bench.srec

