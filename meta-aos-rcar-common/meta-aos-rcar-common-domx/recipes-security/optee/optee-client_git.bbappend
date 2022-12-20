SRC_URI = "git://github.com/OP-TEE/optee_client.git;branch=${BRANCH}"

SRC_URI += " \
    file://optee.service \
"

# optee-client 3.18.0
SRCREV = "e7cba71cc6e2ecd02f412c7e9ee104f0a5dffc6f"

PV = "3.18.0+git${SRCPV}"

COMPATIBLE_MACHINE = "salvator-x|ulcb|ebisu|draak|spider"

EXTRA_OEMAKE += " \
    CFG_TEE_FS_PARENT_PATH=/var/optee \
"

DEPENDS += "python3-cryptography-native"

do_install_append() {
    install -D -p -m 0644 ${S}/out/export/usr/lib/libckteec.so.0.1 ${D}${libdir}/libckteec.so.0.1
    lnr ${D}${libdir}/libckteec.so.0.1 ${D}${libdir}/libckteec.so.0
    lnr ${D}${libdir}/libckteec.so.0.1 ${D}${libdir}/libckteec.so
}
