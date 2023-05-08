#!/bin/bash -eu

SCRIPT_DIR=$(cd `dirname $0` && pwd)
GITHUB_URL=https://github.com/TrampolineRTOS/trampoline
COMMIT=c16eaa6dc14f0648ba9507bb9cfe030786c5ad57
SOURCE_DIR=${SCRIPT_DIR}/trampoline

export PATH=~/.local/bin:$PATH
export PATH=${SCRIPT_DIR}/arm-gnu-toolchain-12.2.rel1-x86_64-arm-none-eabi/bin:${PATH}

CLEAN_BUILD_FLAG=false
Usage() {
    echo "Usage:"
    echo "    $0 [option]"
    echo "option:"
    echo "    -c: Clean build flag(Defualt is disable)"
}
# Proc arguments
while getopts "ch" OPT
do
    case $OPT in
        c) CLEAN_BUILD_FLAG=true;;
        h) Usage; exit;;
        *) echo Unsupported option; Usage; exit;;
    esac
done

# setup cross_compiler
if [[ ! -e "${SCRIPT_DIR}/arm-gnu-toolchain-12.2.rel1-x86_64-arm-none-eabi" ]]; then
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
    git am ${SCRIPT_DIR}/patchset_trampoline/*.patch
fi

# Setup python build env
python3 -m venv ${SOURCE_DIR}/.venv
source ${SOURCE_DIR}/.venv/bin/activate

# build goil binary
cd ${SOURCE_DIR}/goil/makefile-unix
./build.py
export PATH=${SOURCE_DIR}/goil/makefile-unix:${PATH}

# build project
cd ${SOURCE_DIR}/examples/cortex-a/armv8/spider/iccom
bash ./build.sh

# deploy
rm -rf ${SCRIPT_DIR}/deploy
mkdir -p ${SCRIPT_DIR}/deploy
arm-none-eabi-objcopy --adjust-vma 0xe2100000 -O srec --srec-forceS3 iccom_exe.elf $SCRIPT_DIR/deploy/cr52.srec

