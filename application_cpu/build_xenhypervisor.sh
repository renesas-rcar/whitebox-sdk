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

BSP_BRANCH="s4-1.2.2"

# Prepare working directory
if [[ ! -e "${SCRIPT_DIR}/work" || "$CLEAN_BUILD_FLAG" == "true" ]]; then
    cd ${SCRIPT_DIR}
    rm -rf ./work
    mkdir -p ./work
fi
cd ${SCRIPT_DIR}/work

# Preprae yaml file
wget -qN https://raw.githubusercontent.com/renesas-rcar/meta-xt-prod-devel-rcar-gen4/refs/heads/${BSP_BRANCH}/prod-devel-rcar-s4.yaml
cat prod-devel-rcar-s4.yaml ../whitebox-sdk-patch.yaml > ./whitebox-sdk.yaml

# Remove old virtualenv
rm -rf ~/.local/share//virtualenvs/vss-tools*

# To avoid increasing network usage, using local repository
cd ${SCRIPT_DIR}/work
if [[ -d $SCRIPT_DIR/common_data/repo ]]; then
    #bash ../setup_local_repository.sh
    # Replace Yocto path
    sed -i -e 's|url: ".*://.*/|url: "../common_data/repo/|' -e 's/\.git//' ./*.yaml
fi

cd ${SCRIPT_DIR}/work
moulin ./whitebox-sdk.yaml \
    --MACHINE $1 \
    --USING_UFS_AS_STORAGE $USING_UFS \
    --ENABLE_DOMU $USING_DOMU
ninja || ninja
ninja image-full

mkdir -p ${SCRIPT_DIR}/deploy
cp yocto-$1/build-domd/tmp/deploy/images/${1}/bl31-${1}.srec ${SCRIPT_DIR}/deploy/
cp yocto-$1/build-domd/tmp/deploy/images/${1}/tee-${1}.srec ${SCRIPT_DIR}/deploy/
cp yocto-$1/build-domd/tmp/deploy/images/${1}/u-boot-elf-${1}.srec ${SCRIPT_DIR}/deploy/

mv -f full.img $1.${BOOT_DEV}.full.img
gzip -f $1.${BOOT_DEV}.full.img
cp -f $1.${BOOT_DEV}.full.img.gz -t ${SCRIPT_DIR}/deploy

if [[ -e "${SCRIPT_DIR}/work/yocto-$1/build-domd/tmp/deploy/sdk" ]]; then
    find ${SCRIPT_DIR}/work/yocto-$1/build-domd/tmp/deploy/sdk/ | grep '.sh$' | xargs cp -f -t ${SCRIPT_DIR}/work
    find ${SCRIPT_DIR}/work/yocto-$1/build-domd/tmp/deploy/sdk/ | grep '.sh$' | xargs cp -f -t ${SCRIPT_DIR}/deploy
fi

echo "Build finished !"
