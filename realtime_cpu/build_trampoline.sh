#!/bin/bash -eu

SCRIPT_DIR=$(cd `dirname $0` && pwd)
GITHUB_URL=https://github.com/TrampolineRTOS/trampoline
COMMIT=5deaff4941cb086e25859743973af019f2bad27c
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
    git reset --hard ${COMMIT} ; git clean -df

    # prepare Benchmarks code
    rm -rf examples/cortex-a/armv8
    git am ${SCRIPT_DIR}/patchset_trampoline/*.patch
    git submodule init
    git submodule update net/ethernet/lwip

    # Dhrystone
    cd ${SOURCE_DIR}/examples/cortex-a/armv8/spider/sample
    rm -rf ./dhrystone
    wget -c https://fossies.org/linux/privat/old/dhrystone-2.1.tar.gz
    mkdir -p ./dhrystone && tar xf dhrystone-2.1.tar.gz -C ./dhrystone
    cp ./dhrystone/dhry_1.c{,.org}
    cd ./dhrystone
    patch -p0 < ${SCRIPT_DIR}/patchset_trampoline/sample_dhry_1.c.diff
    # Coremark
    cd ..
    rm -rf ./coremark
    git clone https://github.com/eembc/coremark ${SOURCE_DIR}/examples/cortex-a/armv8/spider/sample/coremark
    cd ${SOURCE_DIR}/examples/cortex-a/armv8/spider/sample/coremark
    git reset --hard d5fad6bd094899101a4e5fd53af7298160ced6ab ; git clean -df
    git apply ${SCRIPT_DIR}/patchset_trampoline/sample_coremark.diff

fi

# Setup uart baudrate
if [ "$1" == "s4sk" ]; then
    sed -i 's/-DHSCIF_1843200BPS/-DHSCIF_921600BPS/g' ${SOURCE_DIR}/examples/cortex-a/armv8/spider/benchmark/benchmark.oil
    sed -i 's/-DHSCIF_1843200BPS/-DHSCIF_921600BPS/g' ${SOURCE_DIR}/examples/cortex-a/armv8/spider/iccom/iccom.oil
    sed -i 's/-DHSCIF_1843200BPS/-DHSCIF_921600BPS/g' ${SOURCE_DIR}/examples/cortex-a/armv8/spider/sample/sample.oil
    sed -i 's/-DHSCIF_1843200BPS/-DHSCIF_921600BPS/g' ${SOURCE_DIR}/examples/cortex-a/armv8/spider/ethernet/eth.oil
    sed -i 's/-DHSCIF_1843200BPS/-DHSCIF_921600BPS/g' ${SOURCE_DIR}/examples/cortex-a/armv8/spider/ethernet_basic/eth.oil
    sed -i 's/-DHSCIF_1843200BPS/-DHSCIF_921600BPS/g' ${SOURCE_DIR}/examples/cortex-a/armv8/spider/lwip/lwip.oil
elif [ "$1" == "spider" ];  then
    sed -i 's/-DHSCIF_921600BPS/-DHSCIF_1843200BPS/g' ${SOURCE_DIR}/examples/cortex-a/armv8/spider/benchmark/benchmark.oil
    sed -i 's/-DHSCIF_921600BPS/-DHSCIF_1843200BPS/g' ${SOURCE_DIR}/examples/cortex-a/armv8/spider/iccom/iccom.oil
    sed -i 's/-DHSCIF_921600BPS/-DHSCIF_1843200BPS/g' ${SOURCE_DIR}/examples/cortex-a/armv8/spider/sample/sample.oil
    sed -i 's/-DHSCIF_921600BPS/-DHSCIF_1843200BPS/g' ${SOURCE_DIR}/examples/cortex-a/armv8/spider/ethernet/eth.oil
    sed -i 's/-DHSCIF_921600BPS/-DHSCIF_1843200BPS/g' ${SOURCE_DIR}/examples/cortex-a/armv8/spider/ethernet_basic/eth.oil
    sed -i 's/-DHSCIF_921600BPS/-DHSCIF_1843200BPS/g' ${SOURCE_DIR}/examples/cortex-a/armv8/spider/lwip/lwip.oil
fi

# Setup python build env
python3 -m venv ${SOURCE_DIR}/.venv
source ${SOURCE_DIR}/.venv/bin/activate

# build goil binary
cd ${SOURCE_DIR}/goil/makefile-unix
./build.py
export PATH=${SOURCE_DIR}/goil/makefile-unix:${PATH}

# build project
cd ${SOURCE_DIR}/examples/cortex-a/armv8/spider/sample
bash ./build.sh

# deploy
rm -rf ${SCRIPT_DIR}/deploy
mkdir -p ${SCRIPT_DIR}/deploy
arm-none-eabi-objcopy -O srec --srec-forceS3 sample_exe.elf $SCRIPT_DIR/deploy/cr52.srec

# build eathernet
cd ${SOURCE_DIR}/examples/cortex-a/armv8/spider/ethernet
chmod +x ./build.sh
./build.sh
mkdir -p ${SCRIPT_DIR}/deploy
arm-none-eabi-objcopy -O srec --srec-forceS3 eth_exe.elf $SCRIPT_DIR/deploy/cr52_eth.srec

cd ${SOURCE_DIR}/examples/cortex-a/armv8/spider/lwip
chmod +x ./build.sh
./build.sh
mkdir -p ${SCRIPT_DIR}/deploy
arm-none-eabi-objcopy -O srec --srec-forceS3 lwip_exe.elf $SCRIPT_DIR/deploy/cr52_lwip.srec

cd ${SOURCE_DIR}/examples/cortex-a/armv8/spider/ethernet_basic
chmod +x ./build.sh
./build.sh
mkdir -p ${SCRIPT_DIR}/deploy
arm-none-eabi-objcopy -O srec --srec-forceS3 eth_exe.elf $SCRIPT_DIR/deploy/cr52_eth_basic.srec

# build can demo
cd ${SOURCE_DIR}/examples/cortex-a/armv8/spider/can_demo
chmod +x ./build.sh
./build.sh
mkdir -p ${SCRIPT_DIR}/deploy
arm-none-eabi-objcopy -O srec --srec-forceS3 can_demo_exe.elf $SCRIPT_DIR/deploy/cr52_can_demo.srec

