#!/bin/bash -eu

# $1 í board name; spider or s4sk
if [ "$1" != "spider" ] && [ "$1" != "s4sk" ]; then
    echo "ERROR: Please specify board name: spider or s4sk"
    exit 1
fi

export PATH=~/.local/bin:$PATH
SCRIPT_DIR=$(cd `dirname $0` && pwd)

AOS_VERSION="v1.0.0"

# Prepare working directory
cd ${SCRIPT_DIR}
rm -rf ./work
mkdir -p ./work
cd ./work

# Preprae yaml file
cat ../aos-rcar-gen4.yaml ../aos-rcar-gen4-patch.yaml > ./aos-rcar-gen4-wb.yaml

#############################################
# START: Apply patch for meta-aos-rcar-gen4 #
#############################################
# Remove meta-aos-rcar-gen from repo list
PARTERN='    - type: git
      url: "https://github.com/aoscloud/meta-aos-rcar-gen4.git"
      rev: "v1.0.0"'
sed -i -z "s|${PARTERN//$'\n'/\\n}||" ./aos-rcar-gen4-wb.yaml

# Prepare additional repo
mkdir -p ./yocto
git clone https://github.com/aoscloud/meta-aos-rcar-gen4 \
    ./yocto/meta-aos-rcar-gen4
cd ./yocto/meta-aos-rcar-gen4
git checkout ${AOS_VERSION}
cd ../../

# Apply patch
cd ./yocto/meta-aos-rcar-gen4
git am ../../../patchset_aos/*

# Patch for S4SK
if [ "$1" == "s4sk" ]; then
    git am ../../../patchset_s4sk/*
fi

cd ../../

#############################################
# END: Apply patch for meta-aos-rcar-gen4   #
#############################################

moulin ./aos-rcar-gen4-wb.yaml --TARGET_BOARD=$1
ninja
ninja image-full
gzip full.img
if [[ -e "${SCRIPT_DIR}/work/yocto/build-domd/tmp/deploy/sdk" ]]; then
    find ${SCRIPT_DIR}/work/yocto/build-domd/tmp/deploy/sdk/ -name *.sh | xargs cp -f -t ${SCRIPT_DIR}/work/
fi
echo "Build finished !"
