SUMMARY = "OP-TEE sanity testsuite"
HOMEPAGE = "https://github.com/OP-TEE/optee_test"

LICENSE = "BSD & GPLv2"
LIC_FILES_CHKSUM = "file://${S}/LICENSE.md;md5=daa2bcccc666345ab8940aab1315a4fa"

SRC_URI = "git://github.com/OP-TEE/optee_test.git"

SRCREV = "da5282a011b40621a2cf7a296c11a35c833ed91b"

PV = "3.18.0+git${SRCPV}"

S = "${WORKDIR}/git"

inherit python3native

OPTEE_ARCH_aarch64 = "arm64"
OPTEE_CLIENT_EXPORT = "${STAGING_DIR_HOST}${prefix}"
TEEC_EXPORT         = "${STAGING_DIR_HOST}${prefix}"
TA_DEV_KIT_DIR      = "${STAGING_INCDIR}/optee/export-user_ta_${OPTEE_ARCH}"

DEPENDS = "optee-client optee-os python3-pycryptodome-native python3-cryptography-native"

EXTRA_OEMAKE = " \
    TA_DEV_KIT_DIR=${TA_DEV_KIT_DIR} \
    OPTEE_CLIENT_EXPORT=${OPTEE_CLIENT_EXPORT} \
    TEEC_EXPORT=${TEEC_EXPORT} \
    CROSS_COMPILE_HOST=${TARGET_PREFIX} \
    CROSS_COMPILE_TA=${TARGET_PREFIX} \
    CFLAGS64=--sysroot=${STAGING_DIR_HOST} \
    V=1 \
"

do_compile() {
    # Top level makefile doesn't seem to handle parallel make gracefully
    oe_runmake xtest
    oe_runmake ta
    oe_runmake test_plugin
}

do_install () {
    install -D -p -m0755 ${S}/out/xtest/xtest ${D}${bindir}/xtest
    # install path should match the value set in optee-client/tee-supplicant
    # default TEEC_LOAD_PATH is /lib
    mkdir -p ${D}/lib/optee_armtz/
    install -D -p -m0444 ${S}/out/ta/*/*.ta ${D}/lib/optee_armtz/
    # install plugin(s)
    mkdir -p ${D}${libdir}/tee-supplicant/plugins
    install -D -p -m0444 ${S}/out/supp_plugin/*.plugin ${D}${libdir}/tee-supplicant/plugins/
}

FILES_${PN} += " \
    ${nonarch_base_libdir}/optee_armtz/ \
    ${libdir}/tee-supplicant/plugins/ \
"

# Imports machine specific configs from staging to build
PACKAGE_ARCH = "${MACHINE_ARCH}"
