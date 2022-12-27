FILESEXTRAPATHS_prepend := "${THISDIR}/optee-client:"

SRC_URI += " \
    file://network-block.conf \
"

FILES_${PN} += " \
    ${sysconfdir} \
"

do_install_append() {
    install -d ${D}${sysconfdir}/systemd/system/optee.service.d
    install -m 0644 ${WORKDIR}/network-block.conf ${D}${sysconfdir}/systemd/system/optee.service.d/20-network-block.conf
}
