require ../../meta-arm/meta-arm/recipes-security/optee/optee-os_git.bb

PV = "3.18.0+git${SRCPV}"

SRC_URI = "git://github.com/OP-TEE/optee_os.git"
# optee-os 3.18.0
SRCREV = "1ee647035939e073a2e8dddb727c0f019cc035f1"

DEPENDS += "python3-cryptography-native"

COMPATIBLE_MACHINE = "generic-armv8-xt"

OPTEEFLAVOR = "${XT_OP_TEE_FLAVOUR}"
PLATFORM = "rcar"

libdir[unexport] = "1"

EXTRA_OEMAKE = " -e MAKEFLAGS= \
    PLATFORM=rcar \
    PLATFORM_FLAVOR=${OPTEEFLAVOR} \
    CFG_ARM64_core=y \
    CFG_VIRTUALIZATION=y \
    CROSS_COMPILE_core=${HOST_PREFIX} \
    CROSS_COMPILE_ta_arm64=${HOST_PREFIX} \
    ta-targets=ta_arm64 \
    CFLAGS64=--sysroot=${STAGING_DIR_HOST} \
    CFG_SYSTEM_PTA=y \
    CFG_PKCS11_TA_HEAP_SIZE="(256 * 1024)" \
"

FILES_${PN} += " \
    ${nonarch_base_libdir} \
"

do_deploy[noexec] = "1"

do_install() {
    # install pkcs11 TA
    install -d ${D}${nonarch_base_libdir}/optee_armtz/
    install -p -m 0444 ${S}/out/arm-plat-${PLATFORM}/ta/pkcs11/*.ta ${D}${nonarch_base_libdir}/optee_armtz/
}
