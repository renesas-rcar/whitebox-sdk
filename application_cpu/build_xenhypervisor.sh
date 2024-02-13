#!/bin/bash -eu

CLEAN_BUILD_FLAG=false
USING_UFS=yes
USING_DOMU=no
Usage() {
    echo "Usage:"
    echo "    $0 board [option]"
    echo "board:"
    echo "    - spider: for S4 Spider"
    echo "    - s4sk: for S4 Starter Kit"
    echo "option:"
    echo "    -c: Clean build flag(Defualt is disable)"
    echo "    -m: Using eMMC/SD as rootfs(Defult is UFS)"
    echo "    -u: Using DomU(Default is disable)"
    echo "    -h: Show this usage"
}

if [[ $# < 1 ]] ; then
    echo -e "\e[31mERROR: Please select a board to build \e[m"
    Usage; exit
fi

# $1 í board name; spider or s4sk
if [ "$1" != "spider" ] && [ "$1" != "s4sk" ]; then
    echo -e "\e[31mERROR: Please "input" correct board name: spider or s4sk\e[m"
    Usage; exit
fi

# Proc arguments
OPTIND=2
while getopts "chmu" OPT
do
    case $OPT in
        c) CLEAN_BUILD_FLAG=true;;
        m) USING_UFS=no;;
        u) USING_DOMU=yes;;
        h) Usage; exit;;
        *) echo -e "\e[31mERROR: Unsupported option\e[m"; Usage; exit;;
    esac
done

BOOT_DEV=ufs
if [[ "$USING_UFS" == "no" ]]; then
    BOOT_DEV=mmc
fi


export PATH=~/.local/bin:$PATH
SCRIPT_DIR=$(cd `dirname $0` && pwd)

AOS_VERSION="v1.0.0"

# Prepare working directory
if [[ ! -e "${SCRIPT_DIR}/work" || "$CLEAN_BUILD_FLAG" == "true" ]]; then
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
fi

# To avoid increasing network usage, using local repository
cd ${SCRIPT_DIR}/work
if [[ -d $SCRIPT_DIR/common_data/repo ]]; then
    bash ../setup_local_repository.sh
    # Replace Yocto path
    sed -i -e 's|url: ".*://.*/|url: "../common_data/repo/|' -e 's/\.git//' ./*.yaml
fi

cd ${SCRIPT_DIR}/work
moulin ./aos-rcar-gen4-wb.yaml \
    --TARGET_BOARD $1 \
    --BUILD_DOMD_SDK no \
    --USING_UFS_AS_STORAGE $USING_UFS \
    --ENABLE_DOMU $USING_DOMU
ninja
ninja image-full
mv -f full.img $1.${BOOT_DEV}.full.img
gzip -f $1.${BOOT_DEV}.full.img
if [[ -e "${SCRIPT_DIR}/work/yocto/build-domd/tmp/deploy/sdk" ]]; then
    find ${SCRIPT_DIR}/work/yocto/build-domd/tmp/deploy/sdk/ -name *.sh | xargs cp -f -t ${SCRIPT_DIR}/work/
fi
echo "Build finished !"
