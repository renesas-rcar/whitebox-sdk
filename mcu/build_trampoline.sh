#!/bin/bash -eu

SCRIPT_DIR=$(cd `dirname $0` && pwd)
GITHUB_URL=https://github.com/TrampolineRTOS/trampoline
COMMIT=90adcf3d4d2b8685abd1a6e938c116f43f68c70e
SOURCE_DIR=${SCRIPT_DIR}/trampoline

export PATH=~/.local/bin:$PATH

if [ ! -e ${SOURCE_DIR} ]; then
    git clone ${GITHUB_URL} ${SOURCE_DIR}
fi
cd ${SOURCE_DIR}
git reset --hard ${COMMIT} ; git clean -df

# prepare Benchmarks code
git am ${SCRIPT_DIR}/patchset_trampoline/*.patch


# check path
if [[ "$(which rlink | grep no)" != "" ]]; then
    export PATH="C:\Program Files (x86)\Renesas Electronics\CS+\CC\CC-RH\V2.05.00\bin:${PATH}"
fi
if [[ "${HLNK_DIR:-""}" == "" ]]; then
    export HLNK_DIR="C:\Program Files (x86)\Renesas Electronics\CS+\CC\CC-RH\V2.05.00"
fi

# all make
cd ${SOURCE_DIR}/examples/renesas/one_task
chmod +x ./build.sh
./build.sh

# Generate IPL
cd ${SOURCE_DIR}
rm -f G4MH.srec
objcopy -O srec --srec-forceS3 ${SOURCE_DIR}/examples/renesas/one_task/_build/one_task_exe.abs one_task_exe.s3
rlink ../G4MH_Head.srec one_task_exe.s3 -fo=Stype -ou=G4MH.srec
rm -f one_task_exe.s3

