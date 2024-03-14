#!/bin/bash -eu

SCRIPT_DIR=$(cd `dirname $0` && pwd)
GITHUB_URL=https://github.com/TrampolineRTOS/trampoline
COMMIT=1ff0f13860c756df64b260bfb22913a4538e637d
SOURCE_DIR=${SCRIPT_DIR}/trampoline

export PATH=~/.local/bin:$PATH
export PATH=${SCRIPT_DIR}/arm-gnu-toolchain-12.2.rel1-x86_64-arm-none-eabi/bin:${PATH}

CLEAN_BUILD_FLAG=false
Usage() {
    echo "Usage:"
    echo "    $0 board [option]"
    echo "board:"
    echo "    - spider: R-Car S4 Spider board"
    echo "    - s4sk: R-Car S4 Starter Kit"
    echo "option:"
    echo "    -c: Clean build flag(Defualt is disable)"
    echo "    -h: Show this usage"
}

if [[ $# < 1 ]]; then
    echo -e "\e[31mERROR: Please select a board to build\e[m"
    Usage; exit
fi

if [[ "$1" != "spider" ]] && [[ "$1" != "s4sk" ]]; then
    echo -e "\e[31mERROR: Please "input" correct board name: spider or s4sk\e[m"
    Usage; exit
fi

# Proc arguments
OPTIND=2
while getopts "ch" OPT
do
    case $OPT in
        c) CLEAN_BUILD_FLAG=true;;
        h) Usage; exit;;
        *) echo -e "\e[31mERROR: Unsupported option\e[m"; Usage; exit;;
    esac
done

# setup cross_compiler
if [[ ! -e "${SCRIPT_DIR}/arm-gnu-toolchain-12.2.rel1-x86_64-arm-none-eabi" ]]; then
    cd ${SCRIPT_DIR}
    wget -c https://developer.arm.com/-/media/Files/downloads/gnu/12.2.rel1/binrel/arm-gnu-toolchain-12.2.rel1-x86_64-arm-none-eabi.tar.xz
    tar xf arm-gnu-toolchain-12.2.rel1-x86_64-arm-none-eabi.tar.xz
    rm arm-gnu-toolchain-12.2.rel1-x86_64-arm-none-eabi.tar.xz
fi

# Prepare source
if [[ ! -e ${SOURCE_DIR} || "$CLEAN_BUILD_FLAG" == "true" ]]; then
    if [ ! -e ${SOURCE_DIR} ]; then
        git clone ${GITHUB_URL} ${SOURCE_DIR}
    fi

    cd ${SOURCE_DIR}
    rm -rf ${SOURCE_DIR}/examples/cortex-a-r/armv8/
    git reset --hard ${COMMIT} ; git clean -df

    # prepare whitebox code
    git am ${SCRIPT_DIR}/patchset_trampoline/*.patch
    git submodule init
    git submodule update libraries/net/ethernet/lwip

    # Dhrystone
    cd ${SOURCE_DIR}/examples/cortex-a-r/armv8/spider/sample
    rm -rf ./dhrystone
    wget -c https://fossies.org/linux/privat/old/dhrystone-2.1.tar.gz
    mkdir -p ./dhrystone && tar xf dhrystone-2.1.tar.gz -C ./dhrystone
    cp ./dhrystone/dhry_1.c{,.org}
    cd ./dhrystone
    patch -p0 < ${SCRIPT_DIR}/patchset_trampoline/sample_cr52_dhry_1.c.diff
    # Coremark
    cd ..
    rm -rf ./coremark
    git clone https://github.com/eembc/coremark ${SOURCE_DIR}/examples/cortex-a-r/armv8/spider/sample/coremark
    cd ${SOURCE_DIR}/examples/cortex-a-r/armv8/spider/sample/coremark
    git reset --hard d5fad6bd094899101a4e5fd53af7298160ced6ab ; git clean -df
    git apply ${SCRIPT_DIR}/patchset_trampoline/sample_cr52_coremark.diff

fi

# Setup uart baudrate
if [ "$1" == "s4sk" ]; then
    sed -i 's/-DHSCIF_1843200BPS/-DHSCIF_921600BPS/g' ${SOURCE_DIR}/examples/cortex-a-r/armv8/spider/sample/sample.oil
    sed -i 's/-DHSCIF_1843200BPS/-DHSCIF_921600BPS/g' ${SOURCE_DIR}/examples/cortex-a-r/armv8/spider/sample/sample_not_can.oil
    sed -i 's/-DHSCIF_1843200BPS/-DHSCIF_921600BPS/g' ${SOURCE_DIR}/examples/cortex-a-r/armv8/spider/ethernet/eth.oil
    sed -i 's/spider_can_controller_1/spider_can_controller_0/g' ${SOURCE_DIR}/examples/cortex-a-r/armv8/spider/sample/can_demo.c
elif [ "$1" == "spider" ];  then
    sed -i 's/-DHSCIF_921600BPS/-DHSCIF_1843200BPS/g' ${SOURCE_DIR}/examples/cortex-a-r/armv8/spider/sample/sample.oil
    sed -i 's/-DHSCIF_921600BPS/-DHSCIF_1843200BPS/g' ${SOURCE_DIR}/examples/cortex-a-r/armv8/spider/ethernet/eth.oil
    sed -i 's/spider_can_controller_0/spider_can_controller_1/g' ${SOURCE_DIR}/examples/cortex-a-r/armv8/spider/sample/can_demo.c
fi

# Setup python build env
python3 -m venv ${SOURCE_DIR}/.venv
source ${SOURCE_DIR}/.venv/bin/activate

# build goil binary
cd ${SOURCE_DIR}/goil/makefile-unix
./build.py
export PATH=${SOURCE_DIR}/goil/makefile-unix:${PATH}

# deploy
rm -rf ${SCRIPT_DIR}/deploy
mkdir -p ${SCRIPT_DIR}/deploy

# build sample project
cd ${SOURCE_DIR}/examples/cortex-a-r/armv8/spider/sample
rm -rf sample
rm -rf sample_not_can
chmod +x ./build.sh
./build.sh
arm-none-eabi-objcopy -O srec --srec-forceS3 sample_exe.elf $SCRIPT_DIR/deploy/cr52.srec

# build sample(can disable) project
if [ "$1" == "s4sk" ]; then
    cd ${SOURCE_DIR}/examples/cortex-a-r/armv8/spider/sample
    rm -rf sample
    rm -rf sample_not_can
    chmod +x ./build_not_can.sh
    ./build_not_can.sh
    arm-none-eabi-objcopy -O srec --srec-forceS3 sample_exe.elf $SCRIPT_DIR/deploy/cr52_can_disable.srec
fi

