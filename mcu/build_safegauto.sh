#!/bin/bash -eu

SCRIPT_DIR=$(cd `dirname $0` && pwd)
SOURCE_DIR=${SCRIPT_DIR}/safeg-auto

export PATH=~/.local/bin:$PATH

CLEAN_BUILD_FLAG=false
Usage() {
    echo "Usage:"
    echo "    $0 [option]"
    echo "option:"
    echo "    -c: Clean build flag(Defualt is disable)"
    echo "    -h: Show this usage"
}
# Proc arguments
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
if [[ "$(which rlink | grep no)" != "" ]]; then
    export PATH="C:\Program Files (x86)\Renesas\RH\2_5_0\bin:${PATH}"
fi
if [[ "${HLNK_DIR:-""}" == "" ]]; then
    export HLNK_DIR="C:\Program Files (x86)\Renesas\RH\2_5_0"
fi

if [[ ! -e ${SOURCE_DIR} || "$CLEAN_BUILD_FLAG" == "true" ]]; then
    if [ ! -e ${SOURCE_DIR} ]; then
        git clone https://github.com/toppers/safeg-auto.git ${SOURCE_DIR}
    fi

    cd ${SOURCE_DIR}
    git reset --hard tags/v1.0.0; git clean -df
    git --git-dir= apply -p1 ${SCRIPT_DIR}/toppers/0001-iccom.flash.rte-ADD-iccom-flash-driver-and-rte.patch
    git --git-dir= apply -p1 ${SCRIPT_DIR}/toppers/0002-iccom-Update-protocol-and-change-CTA-address.patch
    git --git-dir= apply -p1 ${SCRIPT_DIR}/toppers/0003-iccom-Change-to-ECHO-for-performance-processing.patch
    git --git-dir= apply -p1 ${SCRIPT_DIR}/toppers/0004-Change-of-G4MH-start-address.patch
    git --git-dir= apply -p1 ${SCRIPT_DIR}/toppers/0005-iccom-Add-get-OS-mode.patch
    wget https://www.toppers.jp/download.cgi/a-rtegen-1.4.0.src.tar.gz
    mkdir vm_atk2/vm1_atk2/common/tool
    tar zxvf a-rtegen-1.4.0.src.tar.gz -C vm_atk2/vm1_atk2/common/tool/
    rm a-rtegen-1.4.0.src.tar.gz
    mv vm_atk2/vm1_atk2/common/tool/a-rtegen vm_atk2/vm1_atk2/common/tool/a-rtegen-1.4.0
    git --git-dir= apply -p1 ${SCRIPT_DIR}/toppers/0001-rte-Add-compile-environment.patch

    # benchmak sample
    git --git-dir= apply -p1 ${SCRIPT_DIR}/patchset_safeg_sample/0001-Marge-benchmark.patch
    cd ${SOURCE_DIR}/vm_atk2/vm1_atk2/
    rm -rf ./dhrystone
    wget -c https://fossies.org/linux/privat/old/dhrystone-2.1.tar.gz
    mkdir -p ./dhrystone && tar xf dhrystone-2.1.tar.gz -C ./dhrystone
    cp ./dhrystone/dhry_1.c{,.org}
    cd ./dhrystone && patch -p0 < ${SCRIPT_DIR}/patchset_safeg_sample/dhry_1.c.diff

    if [ ! -e ${SOURCE_DIR}/vm_atk2/vm1_atk2/coremark ]; then
        git clone https://github.com/eembc/coremark ${SOURCE_DIR}/vm_atk2/vm1_atk2/coremark
    fi
    cd ${SOURCE_DIR}/vm_atk2/vm1_atk2/coremark
    git reset --hard d5fad6bd094899101a4e5fd53af7298160ced6ab ; git clean -df
    git apply ${SCRIPT_DIR}/patchset_safeg_sample/coremark.diff

fi
cd ${SOURCE_DIR}
# set path
opt1='./vm_atk2/vm1_atk2/common/'
opt2='./hypervisor/obj/obj_1pe_atk2/'
opt3='../../..'
opt4='../../..'

# all clean
cd $opt1
sh configure.sh del
cd $opt3
make clean
cd $opt2
make clean
rm -f *.syms
rm -fr objs
rm -f *.mtud
cd $opt4

# all make
cd $opt1
sh configure.sh
cd $opt3
cd $opt2
make
cd $opt3
make depend
make

rm -f G4MH.srec
objcopy -O srec --srec-forceS3 ./hypervisor/obj/obj_1pe_atk2/hypervisor.run hypervisor.s3
objcopy -O srec --srec-forceS3 ./vm_atk2/vm1_atk2/atk2-sc1_vm1.run atk2-sc1_vm1.s3
objcopy -O srec --srec-forceS3 ./vm_atk2/vm2_atk2/atk2-sc1_vm2.run atk2-sc1_vm2.s3

rlink ../G4MH_Head.srec hypervisor.s3 atk2-sc1_vm1.s3 atk2-sc1_vm2.s3 -fo=Stype -ou=G4MH.srec
rm hypervisor.s3 atk2-sc1_vm1.s3 atk2-sc1_vm2.s3

mkdir -p ${SCRIPT_DIR}/deploy
cp -f ./G4MH.srec ${SCRIPT_DIR}/deploy/g4mh.srec
