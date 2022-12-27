FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += " \
    file://optee-identity.conf \
"

FILES_${PN} += " \
    ${sysconfdir} \
"

do_install_append() {
    install -d ${D}${sysconfdir}/systemd/system/${PN}.service.d
    install -m 0644 ${WORKDIR}/optee-identity.conf ${D}${sysconfdir}/systemd/system/${PN}.service.d/20-optee-identity.conf
}
