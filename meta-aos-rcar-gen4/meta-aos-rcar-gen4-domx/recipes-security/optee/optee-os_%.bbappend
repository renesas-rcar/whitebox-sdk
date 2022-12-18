FILESEXTRAPATHS_prepend := "${THISDIR}/optee-os:"

COMPATIBLE_MACHINE = "spider"

PV = "3.17.0+git${SRCPV}"

DEPENDS += "python3-cryptography-native"

SRCREV = "f9e550142dd4b33ee1112f5dd64ffa94ba79cefa"

OPTEEMACHINE = "rcar"
OPTEEOUTPUTMACHINE = "rcar"
OPTEEFLAVOR = "spider_s4"

EXTRA_OEMAKE += " \
    PLATFORM_FLAVOR=${OPTEEFLAVOR} \
    CFG_VIRTUALIZATION=y \
    CFG_VIRT_GUEST_COUNT=3 \
    CFG_TEE_CORE_LOG_LEVEL=0 \
    CFG_TEE_CORE_DEBUG=n \
    CFG_RCAR_UART=103 \
    CFG_PKCS11_TA_HEAP_SIZE="(256 * 1024)" \
"

python __anonymous () {
    d.delVarFlag("do_install", "noexec")
    d.delVarFlag("do_deploy", "noexec")
}

FILES_${PN} += " \
    ${nonarch_base_libdir} \
"

do_install () {
    # install TA devkit
    install -d ${D}${includedir}/optee/export-user_ta/
    for f in ${B}/out/arm-plat-${OPTEEOUTPUTMACHINE}/export-ta_${OPTEE_ARCH}/* ; do
        cp -aR $f ${D}${includedir}/optee/export-user_ta/
    done

    # install pkcs11 TA
    install -d ${D}${nonarch_base_libdir}/optee_armtz/
    install -p -m 0444 ${S}/out/arm-plat-${OPTEEOUTPUTMACHINE}/ta/pkcs11/*.ta ${D}${nonarch_base_libdir}/optee_armtz/
}

do_deploy() {
    # Create deploy folder
    install -d ${DEPLOYDIR}

    # Copy TEE OS to deploy folder
    install -m 0644 ${S}/out/arm-plat-${OPTEEOUTPUTMACHINE}/core/tee.elf ${DEPLOYDIR}/tee-${MACHINE}.elf
    install -m 0644 ${S}/out/arm-plat-${OPTEEOUTPUTMACHINE}/core/tee-raw.bin ${DEPLOYDIR}/tee-${MACHINE}.bin
    install -m 0644 ${S}/out/arm-plat-${OPTEEOUTPUTMACHINE}/core/tee.srec ${DEPLOYDIR}/tee-${MACHINE}.srec
}
