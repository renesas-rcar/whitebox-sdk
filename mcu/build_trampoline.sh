#!/bin/bash -eu

SCRIPT_DIR=$(cd `dirname $0` && pwd)
GITHUB_URL=https://github.com/TrampolineRTOS/trampoline
COMMIT=5deaff4941cb086e25859743973af019f2bad27c
SOURCE_DIR=${SCRIPT_DIR}/trampoline

export PATH=~/.local/bin:$PATH

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
        *) echo -e "\e[31mERROR: Unsupported option \e[m"; Usage; exit;;
    esac
done

# check CC-RH compiler
if [[ "$(ccrh -v; echo $?)" -ne 0 ]]; then
    echo -e "\e[31mERROR: CC-RH compiler may not be installed correctly.\e[m"
    exit -1
fi

if [[ ! -e ${SOURCE_DIR} || "$CLEAN_BUILD_FLAG" == "true" ]]; then
    if [ ! -e ${SOURCE_DIR} ]; then
        git clone ${GITHUB_URL} ${SOURCE_DIR}
    fi
    cd ${SOURCE_DIR}
    git reset --hard ${COMMIT} ; git clean -df

    # prepare Benchmarks code
    git am ${SCRIPT_DIR}/patchset_trampoline/*.patch

    # Dhrystone
    cd ${SOURCE_DIR}/examples/renesas/sample
    rm -rf ./dhrystone
    wget -c https://fossies.org/linux/privat/old/dhrystone-2.1.tar.gz
    mkdir -p ./dhrystone && tar xf dhrystone-2.1.tar.gz -C ./dhrystone
    cp ./dhrystone/dhry_1.c{,.org}
    cd ./dhrystone && patch -p0 < ${SCRIPT_DIR}/patchset_trampoline/sample_dhry_1.c.diff
    # Coremark
    cd ..
    rm -rf ./coremark
    git clone https://github.com/eembc/coremark ${SOURCE_DIR}/examples/renesas/sample/coremark
    cd ${SOURCE_DIR}/examples/renesas/sample/coremark
    git reset --hard d5fad6bd094899101a4e5fd53af7298160ced6ab ; git clean -df
    git apply ${SCRIPT_DIR}/patchset_trampoline/sample_coremark.diff
fi

# Setup uart baudrate
if [ "$1" == "s4sk" ]; then
    sed -i 's/-DHSCIF_1843200BPS/-DHSCIF_921600BPS/g' ${SOURCE_DIR}/examples/renesas/sample/sample.oil
elif [ "$1" == "spider" ];  then
    sed -i 's/-DHSCIF_921600BPS/-DHSCIF_1843200BPS/g' ${SOURCE_DIR}/examples/renesas/sample/sample.oil
fi

if [[ "$(which rlink | grep no)" != "" ]]; then
    export PATH="C:\Program Files (x86)\Renesas\RH\2_5_0\bin:${PATH}"
fi
if [[ "${HLNK_DIR:-""}" == "" ]]; then
    export HLNK_DIR="C:\Program Files (x86)\Renesas\RH\2_5_0"
fi

# Setup python build env for building goil
python3 -m venv ${SOURCE_DIR}/.venv
source ${SOURCE_DIR}/.venv/bin/activate

# build goil binary
cd ${SOURCE_DIR}/goil/makefile-unix
./build.py
export PATH=${SOURCE_DIR}/goil/makefile-unix:${PATH}

# build sample
cd ${SOURCE_DIR}/examples/renesas/sample
chmod +x ./build.sh
./build.sh
cd ${SOURCE_DIR}
rm -f G4MH_sample.srec
objcopy -O srec --srec-forceS3 ${SOURCE_DIR}/examples/renesas/sample/_build/sample_exe.abs sample_exe.s3
rlink ../G4MH_Head.srec sample_exe.s3 -fo=Stype -ou=G4MH_sample.srec
rm -f sample_exe.s3
mkdir -p ${SCRIPT_DIR}/deploy
cp -f G4MH_sample.srec ${SCRIPT_DIR}/deploy/g4mh.srec

