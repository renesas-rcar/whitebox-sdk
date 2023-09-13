#!/bin/bash -eu

CLEAN_BUILD_FLAG=false
Usage() {
    echo "Usage:"
    echo "    $0 board [option]"
    echo "board:"
    echo "    - spider: for S4 Spider"
    echo "    - s4sk: for S4 Starter Kit"
    echo "option:"
    echo "    -c: Clean build flag(Defualt is disable)"
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
while getopts "ch" OPT
do
    case $OPT in
        c) CLEAN_BUILD_FLAG=true;;
        h) Usage; exit;;
        *) echo -e "\e[31mERROR: Unsupported option\e[m"; Usage; exit;;
    esac
done

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
