FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += " \
    file://network-block.conf \
"

FILES_${PN} += " \
    ${sysconfdir} \
"

RDEPENDS_${PN}_remove = " \
    aos-setupdisk \
"

do_install_append() {
    install -d ${D}${sysconfdir}/systemd/system/${PN}.service.d
    install -d ${D}${sysconfdir}/systemd/system/${PN}-provisioning.service.d
    install -m 0644 ${WORKDIR}/network-block.conf ${D}${sysconfdir}/systemd/system/${PN}.service.d/20-network-block.conf
    install -m 0644 ${WORKDIR}/network-block.conf ${D}${sysconfdir}/systemd/system/${PN}-provisioning.service.d/20-network-block.conf
}
