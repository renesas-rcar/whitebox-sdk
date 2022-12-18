COMPATIBLE_MACHINE = "spider"

PV = "3.17.0+git${SRCPV}"

SRCREV = "9a337049c52495e5e16b4a94decaa3e58fce793e"

EXTRA_OEMAKE += " \
    CFG_TEE_FS_PARENT_PATH=/var/optee \
"

do_install_append() {
    install -D -p -m 0644 ${S}/out/export/usr/lib/libckteec.so.0.1 ${D}${libdir}/libckteec.so.0.1
    lnr ${D}${libdir}/libckteec.so.0.1 ${D}${libdir}/libckteec.so.0
    lnr ${D}${libdir}/libckteec.so.0.1 ${D}${libdir}/libckteec.so
}
