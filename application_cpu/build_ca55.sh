#!/bin/bash -eu

export PATH=~/.local/bin:$PATH
SCRIPT_DIR=$(cd `dirname $0` && pwd)

AOS_VERSION="v1.0.0"
DOMD_OLD_SIZE="1024 MiB"
DOMD_NEW_SIZE="2048 MiB"
IMAGE_INSTALL_DOMD="        - [IMAGE_INSTALL_append, \" waii packagegroup-system-monitor iproute2-tc snort docker python3-docker-compose dhrystone whetstone sysbench iccom-lib iccom-test \"]"
IMAGE_INSTALL_DOMU="        - [IMAGE_INSTALL_append, \" iproute2 iproute2-tc\"]"
DOMD_NEW_FILE="        - \"tmp/work/%{MACHINE}-poky-linux/rcar-image-minimal/1.0-r0/rootfs/var/statestorage.db\""
DOM0_BITBAKE_NEW_LAYER="        - \"../../../meta-rcar-whitebox/meta-aos-iccom\""
DOMD_BITBAKE_NEW_LAYER="        - \"../../../meta-rcar-whitebox/meta-rcar-common\"\n        - \"../../../meta-rcar-whitebox/meta-xt-iccomlayer\""
DOMD_VAR_NEW_FILE="          \"statestorage.db\": \"%{YOCTOS_WORK_DIR}/build-domd/tmp/work/%{MACHINE}-poky-linux/rcar-image-minimal/1.0-r0/rootfs/var/statestorage.db\""
OLD_COMMIT=d1e67027b82143bd56cc8a881e11e4d475dcffb9
NEW_COMMIT=e74fea0be1d2553617f13344babdfbeb0cee4eeb

# Download yaml file
cd ${SCRIPT_DIR}
rm -f aos-rcar-gen4.yaml
curl -O https://raw.githubusercontent.com/aoscloud/meta-aos-rcar-gen4/${AOS_VERSION}/aos-rcar-gen4.yaml

# Remove meta-aos-rcar-gen4 from repo list
PARTERN='    - type: git
      url: "https://github.com/aoscloud/meta-aos-rcar-gen4.git"
      rev: "v1.0.0"'
sed -i -z "s|${PARTERN//$'\n'/\\n}||" aos-rcar-gen4.yaml

# Update yaml file
sed -i "s/${DOMD_OLD_SIZE}/${DOMD_NEW_SIZE}/" aos-rcar-gen4.yaml
sed -i "s|\(\".unprovisioned\":.*\"\)|\1\n${DOMD_VAR_NEW_FILE}|" aos-rcar-gen4.yaml
sed -i "s|\(  domu:$\)|${DOMD_NEW_FILE}\n\1|" aos-rcar-gen4.yaml
sed -i "0,/\"..\/meta-aos\"/s|\(\"../meta-aos\"\)|\1\n${DOM0_BITBAKE_NEW_LAYER}|" aos-rcar-gen4.yaml
sed -i "s|\(\"../meta-aos-rcar-gen4/meta-aos-rcar-gen4-driver-domain\"\)|\1\n${DOMD_BITBAKE_NEW_LAYER}|" aos-rcar-gen4.yaml
sed -i "s|\(        - \[XT_DOM_NAME, \"domd\"\]$\)|\1\n${IMAGE_INSTALL_DOMD}|" aos-rcar-gen4.yaml
sed -i "s|\(        - \[XT_DOM_NAME, \"domu\"\]$\)|\1\n${IMAGE_INSTALL_DOMU}|" aos-rcar-gen4.yaml

# Prepare working directory
rm -rf ./work
mkdir -p ./work
cd ./work

# Prepare additional repo
mkdir -p ./yocto
git clone https://github.com/aoscloud/meta-aos-rcar-gen4 \
    ./yocto/meta-aos-rcar-gen4
cd ./yocto/meta-aos-rcar-gen4
git checkout ${AOS_VERSION}
cd ../../

cd ./yocto/meta-aos-rcar-gen4
git am ../../../patchset_aos/*
cd ../../

moulin ../aos-rcar-gen4.yaml
ninja
ninja image-full
echo "Build finished !"
