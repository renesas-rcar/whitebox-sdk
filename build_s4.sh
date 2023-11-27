#!/bin/bash -eu

SCRIPT_DIR=$(cd `dirname $0` && pwd)
cd $SCRIPT_DIR

CLEAN_BUILD_FLAG=false
USE_UFS=no
Usage() {
    echo "Usage:"
    echo "    $0 board [option]"
    echo "board:"
    echo "    - spider: for S4 Spider"
    echo "    - s4sk: for S4 Starter Kit"
    echo "option:"
    echo "    -c: Clean build flag(Defualt is disable)"
    echo "    -u: Use UFS as boot storage(Default is disable)"
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
BOARD=$1

# Proc arguments
OPTIND=2
while getopts "cuh" OPT
do
    case $OPT in
        c) CLEAN_BUILD_FLAG=true;;
        u) USE_UFS=yes;;
        h) Usage; exit;;
        *) echo -e "\e[31mERROR: Unsupported option\e[m"; Usage; exit;;
    esac
done

# Prepare working directory
cd ${SCRIPT_DIR}
if [[ "$CLEAN_BUILD_FLAG" == true || ! -e ./work-s4 ]] ;then
    rm -rf ./work-s4/yocto/build/gen4
    mkdir -p ./work-s4
fi
cd ./work-s4

# Preprae yaml file
cp -f ../aos-rcar-demo2023.yaml ./aos-rcar-demo2023.yaml
# To avoid increasing network usage, using local repository
if [[ -d $SCRIPT_DIR/common_data/repo ]]; then
    bash ../setup_local_repository.sh
    # replace network path with local filepath
    # Replace zephyr path firstly: relative path is not same as yocto
    sed -i -e 's|https://github.com/aoscloud/aos_core_zephyr.git|../../../common_data/repo/aos_core_zephyr|' \
        ./aos-rcar-demo2023.yaml
    sed -i -e 's|v0.2.1|s4sk-dev|' ./aos-rcar-demo2023.yaml
    # Replace Yocto path
    sed -i -e 's|url: ".*://.*/|url: "../common_data/repo/|' -e 's/\.git//' ./aos-rcar-demo2023.yaml
fi

# GEN3_DEVICE: enable/disable/enable-not-build
moulin ./aos-rcar-demo2023.yaml \
    --GEN3_DEVICE enable-not-build \
    --GEN3_MACHINE h3ulcb-4x2g \
    --GEN4_MACHINE $BOARD \
    --USING_UFS_AS_STORAGE $USE_UFS

    #--GEN3_DEVICE disable \

ninja
ninja gen4_full.img.gz
#gzip -f gen4_full.img

exit

ninja gen3_full.img
gzip -f gen3_full.img

