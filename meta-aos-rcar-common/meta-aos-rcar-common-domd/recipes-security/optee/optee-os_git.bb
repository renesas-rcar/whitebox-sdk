FILESEXTRAPATHS_prepend := "${THISDIR}/optee-os:"

DESCRIPTION = "OP-TEE OS"

LICENSE = "BSD"
LIC_FILES_CHKSUM = "file://${S}/LICENSE;md5=c1f21c4f72f372ef38a5a4aee55ec173"

SRC_URI = "git://github.com/OP-TEE/optee_os.git"
# optee-os 3.18.0
SRCREV = "1ee647035939e073a2e8dddb727c0f019cc035f1"

SRC_URI += " \
    file://0001-plat-rcar-fix-core-pos-calculation-for-H3-boards.patch \
"

PV = "3.18.0+git${SRCPV}"

S = "${WORKDIR}/git"

inherit deploy python3native

DEPENDS = "python3-pycryptodome-native python3-pyelftools-native python3-cryptography-native"

COMPATIBLE_MACHINE ?= "(salvator-x|h3ulcb|m3ulcb|m3nulcb|spider)"
OPTEEMACHINE = "rcar"
PLATFORM = "rcar"

OPTEEFLAVOR = "${XT_OP_TEE_FLAVOUR}"

PACKAGE_ARCH = "${MACHINE_ARCH}"
export CROSS_COMPILE64="${TARGET_PREFIX}"

# Let the Makefile handle setting up the flags as it is a standalone application
LD[unexport] = "1"
LDFLAGS[unexport] = "1"
export CCcore="${CC}"
export LDcore="${LD}"
libdir[unexport] = "1"

OPTEE_ARCH_aarch64 = "arm64"

EXTRA_OEMAKE = "-e MAKEFLAGS= \
    PLATFORM=rcar \
    PLATFORM_FLAVOR=${OPTEEFLAVOR} \
    CFG_ARM64_core=y \
    CFG_VIRTUALIZATION=y \
    CROSS_COMPILE_core=${HOST_PREFIX} \
    CROSS_COMPILE_ta_${OPTEE_ARCH}=${HOST_PREFIX} \
    ta-targets=ta_${OPTEE_ARCH} \
    CFLAGS64=--sysroot=${STAGING_DIR_HOST} \
    CFG_SYSTEM_PTA=y \
    CFG_RCAR_UART=103 \
"

do_configure() {
}

do_install () {
    install -d ${D}/usr/include/optee/export-user_ta_${OPTEE_ARCH}/

    for f in ${S}/out/arm-plat-rcar/export-ta_${OPTEE_ARCH}/*; do
        cp -aR $f ${D}/usr/include/optee/export-user_ta_${OPTEE_ARCH}/
    done
}

do_deploy() {
    # Create deploy folder
    install -d ${DEPLOYDIR}

    # Copy TEE OS to deploy folder
    install -m 0644 ${S}/out/arm-plat-${PLATFORM}/core/tee.elf ${DEPLOYDIR}/tee-${MACHINE}.elf
    install -m 0644 ${S}/out/arm-plat-${PLATFORM}/core/tee-raw.bin ${DEPLOYDIR}/tee-${MACHINE}.bin
    install -m 0644 ${S}/out/arm-plat-${PLATFORM}/core/tee.srec ${DEPLOYDIR}/tee-${MACHINE}.srec
}

addtask deploy before do_build after do_compile

FILES_${PN} = ""
FILES_${PN}-staticdev = "/usr/include/optee/"
