#!/bin/bash -eu

SCRIPT_DIR=$(cd `dirname $0` && pwd)
cd $SCRIPT_DIR

CLEAN_BUILD_FLAG=false
ENABLE_DEMO=no
USE_UFS=no
CREATE_FOTA_PKG_FLAG=false
CLUSTER_VER=new
CLUSTER_COLOR=default
BUNDLE_IMAGE_VERSION=0.2.0
Usage() {
    echo "Usage:"
    echo "    $0 board [option]"
    echo "board:"
    echo "    - h3ulcb-4x2g"
    echo "option:"
    echo "    -c: Clean build flag(Defualt is disable)"
    echo "    -d: Enable Demo features(Defult is disable)"
    echo "    -f: Build FOTA package(Default is disable)"
    echo "    -v <version>: Set bundle_image_version(default is 0.2.0)"
    echo "    -t <color>: Select cluster color(default is blue)"
    echo "    -u: Use UFS as boot storage(Default is disable)"
    echo "    -h: Show this usage"
    echo ""
    echo "moulin --help-config"
    moulin --help-config aos-rcar-demo2023.yaml
}

if [[ $# < 1 ]] ; then
    echo -e "\e[31mERROR: Please select a board to build \e[m"
    Usage; exit
fi
# $1 í board name; spider or s4sk
if [ "$1" != "h3ulcb-4x2g" ]; then
    echo -e "\e[31mERROR: Please "input" correct board name: spider or s4sk\e[m"
    Usage; exit
fi
BOARD=$1

# Proc arguments
OPTIND=2
while getopts "cdfv:t:uh" OPT
do
    case $OPT in
        c) CLEAN_BUILD_FLAG=true;;
        d) ENABLE_DEMO=yes;;
        f) CREATE_FOTA_PKG_FLAG=true;;
        v) BUNDLE_IMAGE_VERSION=$OPTARG;;
        t) CLUSTER_COLOR=$OPTARG;;
        u) USE_UFS=yes;;
        h) Usage; exit;;
        *) echo -e "\e[31mERROR: Unsupported option\e[m"; Usage; exit;;
    esac
done

# Setup python env
# python3 -m venv ${SCRIPT_DIR}/common_data/.venv
# source ${SCRIPT_DIR}/common_data/.venv/bin/activate
# pip install wheel
# pip install west
# pip install pyelftools
# pip install protobuf grpcio-tools
# pip install git+https://github.com/xen-troops/moulin

# Prepare working directory
cd ${SCRIPT_DIR}
if [[ "$CLEAN_BUILD_FLAG" == true || ! -e ./work ]] ;then
    rm -rf ./work/yocto
    mkdir -p ./work/yocto
fi
cd ./work

# Preprae yaml file
cp -f ../aos-rcar-demo2023.yaml ./aos-rcar-demo2023.yaml
# To avoid increasing network usage, using local repository
if [[ -d $SCRIPT_DIR/common_data/repo ]]; then
    bash ../setup_local_repository.sh
    # replace network path with local filepath
    # Replace zephyr path firstly: relative path is not same as yocto
    # sed -i -e 's|https://github.com/aoscloud/aos_core_zephyr.git|../../../common_data/repo/aos_core_zephyr|' \
    #     ./aos-rcar-demo2023.yaml
    # sed -i -e 's|v0.2.1|s4sk-dev|' ./aos-rcar-demo2023.yaml
    # Replace Yocto path
    sed -i -e 's|url: ".*://.*/|url: "../common_data/repo/|' -e 's/\.git//' ./aos-rcar-demo2023.yaml
fi

if [[ ${BUNDLE_IMAGE_VERSION:-"0.2.0"} != "0.2.0" ]];then
    sed -i "s/\"0.2.0\"/\"$BUNDLE_IMAGE_VERSION\"/" ./aos-rcar-demo2023.yaml
    V1=$(echo $BUNDLE_IMAGE_VERSION | cut -d'.' -f1)
    V2=$(echo $BUNDLE_IMAGE_VERSION | cut -d'.' -f2)
    V3=$(echo $BUNDLE_IMAGE_VERSION | cut -d'.' -f3)
    #V2=$(( $V2 - 1 ))
    V3=$(( $V3 - 1 ))
    PREV_VER=$V1.$V2.$V3
    sed -i "s/\"0.1.0\"/\"$PREV_VER\"/" ./aos-rcar-demo2023.yaml
    # sed -i "s/aos_domd_ref_version/$PREV_VER/" ./aos-rcar-demo2023.yaml
fi

# GEN3_DEVICE: enable/disable/enable-not-build
moulin ./aos-rcar-demo2023.yaml \
    --GEN3_DEVICE enable \
    --GEN4_DEVICE disable \
    --GEN3_MACHINE $BOARD \
    --GEN4_MACHINE s4sk \
    --USING_UFS_AS_STORAGE $USE_UFS \
    --ENABLE_DEMO $ENABLE_DEMO \
    --SELECT_CLUSTER_COLOR $CLUSTER_COLOR

ninja
ninja gen3_full.img
# Rename Full FOTA package
if [[ -e rcar-demo2023-1.0-gen3-${BUNDLE_IMAGE_VERSION}.tar ]]; then
    mv -f rcar-demo2023-1.0-gen3-${BUNDLE_IMAGE_VERSION}.tar \
        rcar-demo2023-1.0-gen3-${BUNDLE_IMAGE_VERSION}-full.tar
fi
# Build Incremental FOTA package
if [[ -e ./rootfs_repo/rcar-demo2023-1.0-gen3-domd/refs/heads/${PREV_VER:-0.0.0} ]]; then
    ninja gen3-domd-fota-inc
    # Rename Incremental FOTA package
    if [[ -e rcar-demo2023-1.0-gen3-${BUNDLE_IMAGE_VERSION}.tar ]]; then
        mv -f rcar-demo2023-1.0-gen3-${BUNDLE_IMAGE_VERSION}.tar \
            rcar-demo2023-1.0-gen3-${BUNDLE_IMAGE_VERSION}-inc-from-$PREV_VER.tar
    fi
fi
# Compress
if [[ -e $(which pigz) ]];then
    pigz -kf gen3_full.img
else
    gzip -kf gen3_full.img
fi
# if [[ "$CREATE_FOTA_PKG_FLAG" == "true" ]]; then
#     ninja gen3-domd-fota-inc
#     # Rename Incremental FOTA package
#     mv rcar-demo2023-1.0-gen3-${BUNDLE_IMAGE_VERSION}.tar rcar-demo2023-1.0-gen3-${BUNDLE_IMAGE_VERSION}-inc-from-$PREV_VER.tar
# else
#     ninja gen3_full.img
#     gzip -kf gen3_full.img
# fi

