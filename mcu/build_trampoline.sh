#!/bin/bash -eu

SCRIPT_DIR=$(cd `dirname $0` && pwd)
GITHUB_URL=https://github.com/TrampolineRTOS/trampoline
COMMIT=d930f9447a237feb062ef3040b980cb9d2b748e7
SOURCE_DIR=${SCRIPT_DIR}/trampoline
export WINEDEBUG=fixme-all

export PATH=${SCRIPT_DIR}/../tool/CC-RH/bin:$PATH
export HLNK_DIR="${SCRIPT_DIR}/../tool/CC-RH"

CLEAN_BUILD_FLAG=false
DISABLE_WARN_MSG_FLAG=false
Usage() {
    echo "Usage:"
    echo "    $0 board [option]"
    echo "board:"
    echo "    - spider: R-Car S4 Spider board"
    echo "    - s4sk: R-Car S4 Starter Kit"
    echo "option:"
    echo "    -c: Clean build flag(Defualt is disable)"
    echo "    -h: Show this usage"
    echo "    -w: Disable warning message about CC-RH compiler for Linux"
}

print_err () {
    echo -e "\e[31m$*\e[m"
}
print_warn () {
    echo -e "\e[33m$*\e[m"
}

if [[ $# < 1 ]]; then
    print_err "ERROR: Please select a board to build"
    Usage; exit
fi

if [[ "$1" != "spider" ]] && [[ "$1" != "s4sk" ]]; then
    print_err "ERROR: Please \"input\" correct board name: spider or s4sk"
    Usage; exit
fi

# Proc arguments
OPTIND=2
while getopts "chw" OPT
do
    case $OPT in
        c) CLEAN_BUILD_FLAG=true;;
        h) Usage; exit;;
        w) DISABLE_WARN_MSG_FLAG=true;;
        *) print_err "ERROR: Unsupported option"; Usage; exit;;
    esac
done

# check CC-RH compiler
if [ ! -e "${SCRIPT_DIR}/../tool/CC-RH/bin" ]; then
    export PATH=~/.local/bin:$PATH
    export HLNK_DIR="C:\Program Files (x86)\Renesas\RH\2_5_0"
    export PATH="C:\Program Files (x86)\Renesas\RH\2_5_0\bin:${PATH}"
    if [[ "$DISABLE_WARN_MSG_FLAG" == "false" ]]; then
        print_warn "Note: CC-RH compiler for Linux isn't found in tool directory."
        print_warn "          ${SCRIPT_DIR}/../tool/CC-RH/bin"
        print_warn "      Whitebox SDK has changed to use linux native compiler since v5.4."
        print_warn "      So please run setup again."
        print_warn "      "
        print_warn "      If you want to disable this message temporarily, please use -w option."
        print_warn "      However, Windows compiler with Wine is deprecated and longer supported."
        print_warn "      "
        print_warn "      Program will proceed after 5 sec"
        sleep 5s
    fi
fi
if [[ "$(ccrh -v; echo $?)" -ne 0 ]]; then
    print_err "ERROR: CC-RH compiler may not be installed correctly."
    exit -1
fi

if [[ ! -e ${SOURCE_DIR} || "$CLEAN_BUILD_FLAG" == "true" ]]; then
    if [ ! -e ${SOURCE_DIR} ]; then
        git clone ${GITHUB_URL} ${SOURCE_DIR}
    fi
    cd ${SOURCE_DIR}
    git reset --hard ${COMMIT} ; git clean -df

    # prepare whitebox code
    git am ${SCRIPT_DIR}/patchset_trampoline/*.patch

    # Dhrystone
    cd ${SOURCE_DIR}/examples/rh850/sample
    rm -rf ./dhrystone
    wget -c https://fossies.org/linux/privat/old/dhrystone-2.1.tar.gz
    mkdir -p ./dhrystone && tar xf dhrystone-2.1.tar.gz -C ./dhrystone
    cp ./dhrystone/dhry_1.c{,.org}
    cd ./dhrystone && patch -p0 < ${SCRIPT_DIR}/patchset_trampoline/sample_dhry_1.c.diff
    # Coremark
    cd ..
    rm -rf ./coremark
    git clone https://github.com/eembc/coremark ${SOURCE_DIR}/examples/rh850/sample/coremark
    cd ${SOURCE_DIR}/examples/rh850/sample/coremark
    git reset --hard d5fad6bd094899101a4e5fd53af7298160ced6ab ; git clean -df
    git apply ${SCRIPT_DIR}/patchset_trampoline/sample_coremark.diff
fi

# Setup uart baudrate
if [ "$1" == "s4sk" ]; then
    sed -i 's/-DHSCIF_1843200BPS/-DHSCIF_921600BPS/g' ${SOURCE_DIR}/examples/rh850/sample/sample.oil
    sed -i 's/-DHSCIF_1843200BPS/-DHSCIF_921600BPS/g' ${SOURCE_DIR}/examples/rh850/sample/sample_not_can.oil
elif [ "$1" == "spider" ];  then
    sed -i 's/-DHSCIF_921600BPS/-DHSCIF_1843200BPS/g' ${SOURCE_DIR}/examples/rh850/sample/sample.oil
    sed -i 's/-DHSCIF_921600BPS/-DHSCIF_1843200BPS/g' ${SOURCE_DIR}/examples/rh850/sample/sample_not_can.oil
fi

# Setup python build env for building goil
python3 -m venv ${SOURCE_DIR}/.venv
source ${SOURCE_DIR}/.venv/bin/activate

# build goil binary
cd ${SOURCE_DIR}/goil/makefile-unix
./build.py
export PATH=${SOURCE_DIR}/goil/makefile-unix:${PATH}

# deploy
rm -rf ${SCRIPT_DIR}/deploy
mkdir -p ${SCRIPT_DIR}/deploy

# build sample
cd ${SOURCE_DIR}/examples/rh850/sample
chmod +x ./build.sh
./build.sh
cd ${SOURCE_DIR}
rm -f G4MH_sample.srec
objcopy -O srec --srec-forceS3 ${SOURCE_DIR}/examples/rh850/sample/_build/sample_exe.abs sample_exe.s3
rlink ../G4MH_Head.srec sample_exe.s3 -fo=Stype -ou=G4MH_sample.srec
rm -f sample_exe.s3
cp -f G4MH_sample.srec ${SCRIPT_DIR}/deploy/g4mh.srec

# build sample(can disable)
if [ "$1" == "s4sk" ]; then
    cd ${SOURCE_DIR}/examples/rh850/sample
    chmod +x ./build_not_can.sh
    ./build_not_can.sh
    cd ${SOURCE_DIR}
    rm -f G4MH_sample.srec
    objcopy -O srec --srec-forceS3 ${SOURCE_DIR}/examples/rh850/sample/_build/sample_exe.abs sample_exe.s3
    rlink ../G4MH_Head.srec sample_exe.s3 -fo=Stype -ou=G4MH_sample.srec
    rm -f sample_exe.s3
    cp -f G4MH_sample.srec ${SCRIPT_DIR}/deploy/g4mh_can_disable.srec
fi

