#!/bin/bash -eu

export PATH=~/.local/bin:$PATH
SCRIPT_DIR=$(cd `dirname $0` && pwd)
AOS_VERSION="v1.0.0"
WHITEBOX_VERSION="v3.1"

# Check propieray package
GUIDE_PATH=$(find ${SCRIPT_DIR}/proprietary -name "R-Car_S4_SDK_start_up_guide_content*.zip" | head -1)
TOOL_PATH=$(find ${SCRIPT_DIR}/proprietary -name "rcar_tool_ubuntu*.zip" | head -1)
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

# Move to working direcotry
if [[ "${CLEAN_BUILD_FLAG:-false}" == "true" ]]; then
    rm -rf ${SCRIPT_DIR}/work/s4_build
fi
mkdir -p ${SCRIPT_DIR}/work/s4_build
cd ${SCRIPT_DIR}/work/s4_build

# Setup yaml file
curl -O https://raw.githubusercontent.com/aoscloud/meta-aos-rcar-gen4/${AOS_VERSION}/aos-rcar-gen4.yaml
curl -O https://raw.githubusercontent.com/renesas-rcar/whitebox-sdk/${WHITEBOX_VERSION}/application_cpu/aos-rcar-gen4-patch.yaml
cat aos-rcar-gen4.yaml aos-rcar-gen4-patch.yaml ${SCRIPT_DIR}/aos-rcar-gen4-demo-patch.yaml \
    > ${SCRIPT_DIR}/work/s4_build/aos-rcar-gen4-demo.yaml

# Remove meta-aos-rcar-gen4 from repo list
PARTERN='    - type: git
      url: "https://github.com/aoscloud/meta-aos-rcar-gen4.git"
      rev: "v1.0.0"'
apply_patch_meta-aos-rcar-gen4 () {
    cd ${SCRIPT_DIR}/work/s4_build
    sed -i -z "s|${PARTERN//$'\n'/\\n}||" ./aos-rcar-gen4-demo.yaml

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
        URL=https://raw.githubusercontent.com/renesas-rcar/whitebox-sdk/${WHITEBOX_VERSION}/application_cpu/patchset_aos/${patch}
        curl -s $URL | git apply
    done
}
apply_patch_meta-aos-rcar-gen4

# Build image
cd ${SCRIPT_DIR}/work/s4_build
moulin ./aos-rcar-gen4-demo.yaml --BUILD_DOMD_SDK=no
ninja
ninja image-full
gzip -kf full.img
mv {,demo.}full.img.gz

# Extract ipl from proprietary package
prepare_ipl () {
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
prepare_ipl

echo "Build finished !"

