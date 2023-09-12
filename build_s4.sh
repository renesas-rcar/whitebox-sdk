#!/bin/bash -eu

export PATH=~/.local/bin:$PATH
SCRIPT_DIR=$(cd `dirname $0` && pwd)
AOS_VERSION="v1.0.0"
WHITEBOX_VERSION="v4.0"
TARGET_BOARD=""
BOARD_LIST=("spider" "s4sk")

GUIDE_PATH=$(find ${SCRIPT_DIR}/proprietary -name "R-Car_S4_SDK_start_up_guide_content*.zip" | head -1)
TOOL_PATH=$(find ${SCRIPT_DIR}/proprietary -name "rcar_tool_ubuntu*.zip" | head -1)
IPL_PATH=$(find ${SCRIPT_DIR}/proprietary -name "ICUMX_Loader_and_Flashwriter_Package_*.zip" | head -1)

#================================================
# Usage
#================================================
Usage() {
    echo "Usage:"
    echo "    $0 board [option]"
    echo "board:"
    for i in ${BOARD_LIST[@]}; do echo "  - $i"; done
    echo "option:"
    echo "    -h: Show this usage"
}

#================================================
# Check commandline args
#================================================
proc_args () {
    for board in ${BOARD_LIST[*]}; do
        if [[ "$board" == "${1:-}" ]]; then
            TARGET_BOARD=$1
            shift 1
        fi
    done
    if [[ -z ${TARGET_BOARD} ]]; then
        Usage; exit;
    fi

    while getopts "h" OPT
    do
        case $OPT in
            h) Usage; exit;;
            *) echo Unsupported option; Usage; exit;;
        esac
    done
}

#================================================
# Check propieray package
#================================================
check_proprietary_package_spider() {
    err_msg () {
        echo "ERROR: Proprietary packages are not found:"
        echo "  - ${SCRIPT_DIR}/proprietary/R-Car_S4_SDK_start_up_guide_content*.zip"
        echo "  - ${SCRIPT_DIR}/proprietary/rcar_tool_ubuntu*.zip"
        echo ""
        echo "Please download following files from renesas.com:"
        echo "  - https://www.renesas.com/r-car-s4#downloads"
        echo "    - R-Car S4 SDK Start Up Guide PKG v(VERSION)"
        echo "    - R-Car S4 SDK common tool for ubuntu v(VERSION)"
        echo "Note: version 3.14.0 or later is recommended"
    }
    if [[ ! -e "${GUIDE_PATH}" ]]; then
        err_msg; exit -1
    fi
    if [[ ! -e "${TOOL_PATH}" ]]; then
        err_msg; exit -1
    fi
}

check_proprietary_package_s4sk() {
    err_msg () {
        echo "ERROR: Proprietary packages are not found:"
        echo "  - ${SCRIPT_DIR}/proprietary/ICUMX_Loader_and_Flashwriter_Package_*.zip"
        echo ""
        echo "Please download following files from renesas.com:"
        echo "  - https://www.renesas.com/us/en/icumx-loader-and-flash-writer-package-r-car-s4-starter-kit"
        echo "    - ICUMX Loader and Flash writer Package for R-Car S4 Starter Kit for SDK v(VERSION)"
        echo "Note: version 3.16.0 or later is recommended"
    }
    if [[ ! -e "${IPL_PATH}" ]]; then
        err_msg; exit -1
    fi
}

#================================================
# build_sw
#================================================
build_sw() {
    # Move to working direcotry
    if [[ "${CLEAN_BUILD_FLAG:-false}" == "true" ]]; then
        rm -rf ${SCRIPT_DIR}/work/s4_build
    fi
    mkdir -p ${SCRIPT_DIR}/work/s4_build
    cd ${SCRIPT_DIR}/work/s4_build

    # Setup yaml file
    curl -O https://raw.githubusercontent.com/renesas-rcar/whitebox-sdk/${WHITEBOX_VERSION}/application_cpu/aos-rcar-gen4.yaml
    curl -O https://raw.githubusercontent.com/renesas-rcar/whitebox-sdk/${WHITEBOX_VERSION}/application_cpu/aos-rcar-gen4-patch.yaml
    cat aos-rcar-gen4.yaml aos-rcar-gen4-patch.yaml ${SCRIPT_DIR}/aos-rcar-gen4-demo-patch.yaml \
        > ${SCRIPT_DIR}/work/s4_build/aos-rcar-gen4-demo.yaml

    # Apply append patch for repository
    apply_patch_meta-aos-rcar-gen4 () {
        cd ${SCRIPT_DIR}/work/s4_build
        # Remove meta-aos-rcar-gen4 from repo list
        sed -i '49,51d' ${SCRIPT_DIR}/work/s4_build/aos-rcar-gen4-demo.yaml

        # Prepare additional repo
        mkdir -p ./yocto
        if [[ ! -e "./yocto/meta-aos-rcar-gen4" ]]; then
            git clone https://github.com/aoscloud/meta-aos-rcar-gen4 \
                ./yocto/meta-aos-rcar-gen4
        fi
        cd ./yocto/meta-aos-rcar-gen4
        git reset --hard ${AOS_VERSION}; git clean -df

        PATCHSET=(
            "0001-domd-Update-Linux-Kernel-to-latest-v5.10.41-rcar-5.1.patch"
            "0002-domd-Add-Snort-and-required-S4-R-Switch-specific-lib.patch"
            "0003-domd-Add-traffic-control-tool.patch"
            "0004-README.md-Update-release-information-and-links.patch"
            "0005-net-renesas-rswitch-fix-disabling-offload-with-defau.patch"
        )
        for patch in ${PATCHSET[@]}; do
            BASE_URL=https://raw.githubusercontent.com/renesas-rcar/whitebox-sdk/${WHITEBOX_VERSION}
            URL=${BASE_URL}/application_cpu/patchset_aos/${patch}
            curl -s $URL | git apply
        done

        # Additional patchset for s4sk
        if [[ "$TARGET_BOARD" == "s4sk" ]]; then
            PATCHSET=(
                "0001-dom0-kernel-update-to-rcar-5.1.7.rc11.patch"
                "0002-domd-linux-Update-Linux-BSP-to-rcar-5.1.7.rc11.patch"
                "0003-domd-kernel-Align-patch-0002-PCIe-MSI-support.patch.patch"
                "0004-domd-kernel-Align-patch-0006-net-renesas-rswitch-fix.patch"
                "0005-domd-kernel-Add-S4SK-dts-for-Xen-and-DomD.patch"
                "0006-domd-snort-Remove-tsn2-service.patch"
                "0007-domu-kernel-Update-to-rcar-5.1.7.rc11.patch"
                "0008-driver-xen-Update-config-fragment-for-S4SK.patch"
                "0009-control-guests-Update-config-file-for-S4SK.patch"
                "0010-common-xt-log-Change-git-protocol-to-https.patch"
                "0011-domx-optee-Add-S4SK-compatible-string.patch"
                "0012-u-boot-Limit-the-revision-for-S4-Spider-only.patch"
                "0013-control-domain-Add-S4SK-image-check.patch"
                "0014-domd-base-files-Set-longer-time-to-wait-for-devices.patch"
                "0015-HACK-s4-perform-direct-reset.patch"
            )
            for patch in ${PATCHSET[@]}; do
                BASE_URL=https://raw.githubusercontent.com/renesas-rcar/whitebox-sdk/${WHITEBOX_VERSION}
                URL=${BASE_URL}/application_cpu/patchset_s4sk/${patch}
                curl -s $URL | git apply
            done
        fi
    }
    apply_patch_meta-aos-rcar-gen4

    # Build image
    cd ${SCRIPT_DIR}/work/s4_build
    moulin ./aos-rcar-gen4-demo.yaml \
        --TARGET_BOARD ${TARGET_BOARD} \
        --BUILD_DOMD_SDK no \
        --ENABLE_AWS no
    ninja
    ninja image-full
    gzip -f full.img
    mv full.img.gz ${TARGET_BOARD}.demo.full.img.gz
}

#================================================
# Extract ipl from proprietary package
#================================================
prepare_ipl_spider () {
    OUTPUT_DIR=${SCRIPT_DIR}/work/s4_build/s4_ipl
    TEMP_DIR=${SCRIPT_DIR}/work/s4_build/s4_ipl_temp
    rm -rf ${OUTPUT_DIR} ${TEMP_DIR}
    mkdir -p ${TEMP_DIR}

    # Extract Xen Hypervisor IPL
    TOOL_PATH=$(find ${SCRIPT_DIR}/proprietary -name "rcar_tool_ubuntu*.zip" | head -1)
    unzip -qo ${TOOL_PATH} -d ${TEMP_DIR}
    TOOL_PATH=$(find ${TEMP_DIR} -name "rcar-xos_tool_hypervisor*.tar.gz" | head -1)
    tar xf ${TOOL_PATH} -C ${TEMP_DIR}
    TOOL_PATH=$(find ${TEMP_DIR} -name "R-Car_S4_Xen*.zip" | head -1)
    unzip -qo ${TOOL_PATH} -d ${TEMP_DIR}
    TOOL_PATH=$(find ${TEMP_DIR} -name "Flash_Boot.zip" | head -1)
    unzip -qo ${TOOL_PATH} -d ${TEMP_DIR}
    mv ${TEMP_DIR}/Flash_Boot ${OUTPUT_DIR}

    # Extract teraterm macro
    GUIDE_PATH=$(find ${SCRIPT_DIR}/proprietary -name "R-Car_S4_SDK_start_up_guide_content*.zip" | head -1)
    unzip -qo ${GUIDE_PATH} -d ${TEMP_DIR}
    GUIDE_PATH=$(find ${TEMP_DIR} -name "R-CarS4_SDK_StartupGuide*.zip" | head -1)
    unzip -qo ${GUIDE_PATH} -d ${TEMP_DIR}
    MACRO_PATH=$(find ${TEMP_DIR} -name "*.ttl" | head -1)
    cp ${MACRO_PATH} ${OUTPUT_DIR}/Flash_Bootloaders_S4.ttl

    # patch to teraterm macro
    sed -e 's/dummy_rtos/App_CDD_ICCOM_S4_Sample_CR52/' \
        -e 's/dummy_g4mh_case0/App_CDD_ICCOM_S4_Sample_G4MH/' \
        -e 's/bl31-spider/bl31/' \
        -e 's/tee-spider/tee/' \
        -e 's/u-boot-elf-spider/u-boot-elf/' \
        -i ${OUTPUT_DIR}/Flash_Bootloaders_S4.ttl

    # Cleanup temp dir
    rm -rf ${TEMP_DIR}

    # Copy U-boot binary
    cp -f ${SCRIPT_DIR}/work/s4_build/yocto/build-domd/tmp/deploy/images/spider/u-boot-elf-spider.srec \
        ${OUTPUT_DIR}/u-boot-elf.srec
}

#================================================
# Extract ipl from proprietary package
#================================================
prepare_ipl_s4sk () {
    OUTPUT_DIR=${SCRIPT_DIR}/work/s4_build/s4_ipl
    TEMP_DIR=${SCRIPT_DIR}/work/s4_build/s4_ipl_temp
    rm -rf ${OUTPUT_DIR} ${TEMP_DIR}
    mkdir -p ${TEMP_DIR}

    # Extract Xen Hypervisor IPL
    unzip -qo ${IPL_PATH} -d ${TEMP_DIR}
    mv ${TEMP_DIR}/* ${OUTPUT_DIR}

    # Copy U-boot binary
    cp -f ${SCRIPT_DIR}/work/s4_build/yocto/build-domd/tmp/deploy/images/${TARGET_BOARD}/*.srec \
        -t ${OUTPUT_DIR}

    # Cleanup temp dir
    rm -rf ${TEMP_DIR}
}

#================================================
# main func
#================================================
proc_args $@
check_proprietary_package_$TARGET_BOARD
build_sw
prepare_ipl_$TARGET_BOARD

echo "Build finished !"

