PV = "3.18.0+git${SRCPV}"
# optee-client 3.18.0
SRCREV = "e7cba71cc6e2ecd02f412c7e9ee104f0a5dffc6f"

COMPATIBLE_MACHINE = "generic-armv8-xt"

EXTRA_OEMAKE += " \
    CFG_TEE_FS_PARENT_PATH=/var/optee \
"

do_install_append() {
    install -D -p -m 0644 ${S}/out/export/usr/lib/libckteec.so.0.1 ${D}${libdir}/libckteec.so.0.1
    lnr ${D}${libdir}/libckteec.so.0.1 ${D}${libdir}/libckteec.so.0
    lnr ${D}${libdir}/libckteec.so.0.1 ${D}${libdir}/libckteec.so
}
