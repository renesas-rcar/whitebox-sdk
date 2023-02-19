#!/bin/bash -eu

SCRIPT_DIR=$(cd `dirname $0` && pwd)
SOURCE_DIR=${SCRIPT_DIR}/safeg-auto-bench
export PATH=~/.local/bin:$PATH

if [ ! -e ${SOURCE_DIR} ]; then
    git clone https://github.com/toppers/safeg-auto.git ${SOURCE_DIR}
fi
cd ${SOURCE_DIR}
git reset --hard tags/v1.0.0 ; git clean -df

# prepare Benchmarks code
git am ${SCRIPT_DIR}/benchmark/*.patch

cd ${SOURCE_DIR}/vm_atk2/vm2_atk2/
rm -rf ./dhrystone
wget -c https://fossies.org/linux/privat/old/dhrystone-2.1.tar.gz
mkdir -p ./dhrystone && tar xf dhrystone-2.1.tar.gz -C ./dhrystone
cp ./dhrystone/dhry_1.c{,.org}
cd ./dhrystone && patch -p0 < ${SCRIPT_DIR}/benchmark/dhry_1.c.diff

if [ ! -e ${SOURCE_DIR}/vm_atk2/vm2_atk2/coremark ]; then
    git clone https://github.com/eembc/coremark ${SOURCE_DIR}/vm_atk2/vm2_atk2/coremark
fi
cd ${SOURCE_DIR}/vm_atk2/vm2_atk2/coremark
git reset --hard d5fad6bd094899101a4e5fd53af7298160ced6ab ; git clean -df
git apply ${SCRIPT_DIR}/benchmark/coremark.diff

# check path
if [[ "$(which rlink | grep no)" != "" ]]; then
    export PATH="C:\Program Files (x86)\Renesas Electronics\CS+\CC\CC-RH\V2.05.00\bin:${PATH}"
fi
if [[ "${HLNK_DIR:-""}" == "" ]]; then
    export HLNK_DIR="C:\Program Files (x86)\Renesas Electronics\CS+\CC\CC-RH\V2.05.00"
fi

# all make
cd ${SOURCE_DIR}
make

rm -f G4MH.srec
objcopy -O srec --srec-forceS3 ./hypervisor/obj/obj_1pe_atk2/hypervisor.elf hypervisor.s3
objcopy -O srec --srec-forceS3 ./vm_atk2/vm1_atk2/atk2-sc1_vm1.elf atk2-sc1_vm1.s3
objcopy -O srec --srec-forceS3 ./vm_atk2/vm2_atk2/atk2-sc1_vm2.elf atk2-sc1_vm2.s3

rlink ../G4MH_Head.srec hypervisor.s3 atk2-sc1_vm1.s3 atk2-sc1_vm2.s3 -fo=Stype -ou=G4MH.srec
rm hypervisor.s3 atk2-sc1_vm1.s3 atk2-sc1_vm2.s3


