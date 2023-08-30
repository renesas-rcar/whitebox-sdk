#!/bin/bash -eu

export PATH=~/.local/bin:$PATH
SCRIPT_DIR=$(cd `dirname $0` && pwd)
AOS_VERSION="v1.0.0"
WHITEBOX_VERSION="v3.1"
#GUIDE_PATH=$(find ${SCRIPT_DIR}/proprietary -name "R-Car_S4_SDK_start_up_guide_content*.zip" | sort -r | head -1)
TOOL_PATH=$(find ${SCRIPT_DIR}/proprietary -name "rcar_tool_ubuntu*.zip" | sort -r | head -1)

# Check propieray package
check_proprietary_package() {
    err_msg () {
        echo "ERROR: Proprietary packages are not found:"
        # echo "  - ${SCRIPT_DIR}/proprietary/R-Car_S4_SDK_start_up_guide_content*.zip"
        echo "  - ${SCRIPT_DIR}/proprietary/rcar_tool_ubuntu*.zip"
        echo ""
        echo "Please download following files from renesas.com:"
        echo "  - https://www.renesas.com/r-car-s4#downloads"
        # echo "    - R-Car S4 SDK Start Up Guide PKG v(VERSION)"
        echo "    - R-Car S4 SDK common tool for ubuntu v(VERSION)"
        echo "Note: version 3.16.0 or later is recommended"
    }
    # if [[ ! -e "${GUIDE_PATH}" ]]; then
    #     err_msg; exit -1
    # fi
    if [[ ! -e "${TOOL_PATH}" ]]; then
        err_msg; exit -1
    fi
}

build_sw() {
    # Move to working direcotry
    if [[ "${CLEAN_BUILD_FLAG:-false}" == "true" ]]; then
        rm -rf ${SCRIPT_DIR}/work/s4_build
    fi
    mkdir -p ${SCRIPT_DIR}/work/s4_build
    cd ${SCRIPT_DIR}/work/s4_build

    # WIP support
    if [[ ! -e whitebox-sdk ]]; then
        git clone --depth=1 https://github.com/renesas-rcar/whitebox-sdk -b v3.0
    fi
    cd whitebox-sdk
    git reset --hard v3.0
    git am ${SCRIPT_DIR}/s4sk-patchset/*.patch
    cd application_cpu
    mkdir -p $SCRIPT_DIR/work/common_data
    ln -sdf $SCRIPT_DIR/work/common_data ./common_data
    ############################################################
    # use mirror repository                                    #
    ############################################################
    sed -i \
        -e "s|git://git.openembedded.org|https://github.com/openembedded|" \
        -e "s|git://git.yoctoproject.org/poky|https://github.com/yoctoproject/poky|" \
        ./aos-rcar-gen4-s4sk.yaml
    ############################################################
    ./build_ca55.sh s4sk
    mv -f ./work/full.img.gz ${SCRIPT_DIR}/work/s4_build/s4sk.demo.full.img.gz
}

# Extract ipl from proprietary package
prepare_ipl () {
    echo $TOOL_PATH
    # echo $GUIDE_PATH

    OUTPUT_DIR=${SCRIPT_DIR}/work/s4_build/s4_ipl
    TEMP_DIR=${SCRIPT_DIR}/work/s4_build/s4_ipl_temp
    rm -rf ${OUTPUT_DIR} ${TEMP_DIR}
    mkdir -p ${TEMP_DIR}

    # Extract Xen Hypervisor IPL
    unzip -qo ${TOOL_PATH} -d ${TEMP_DIR}
    TOOL_PATH=$(find ${TEMP_DIR} -name "rcar-xos_tool_hypervisor*.tar.gz" | head -1)
    tar xf ${TOOL_PATH} -C ${TEMP_DIR}
    TOOL_PATH=$(find ${TEMP_DIR} -name "R-Car_S4_Xen*.zip" | head -1)
    unzip -qo ${TOOL_PATH} -d ${TEMP_DIR}
    TOOL_PATH=$(find ${TEMP_DIR} -name "Flash_Boot.zip" | grep S4SK)
    unzip -qo ${TOOL_PATH} -d ${TEMP_DIR}
    mv ${TEMP_DIR}/Flash_Boot ${OUTPUT_DIR}

    # Copy U-Boot binary
    cp ./work/yocto/build-domd/tmp/deploy/images/s4sk/u-boot-elf-s4sk.srec \
        -t ${SCRIPT_DIR}/work/s4_build/s4_ipl

    # Cleanup temp dir
    rm -rf ${TEMP_DIR}
}


build_sw
check_proprietary_package
prepare_ipl

echo "Build finished !"

