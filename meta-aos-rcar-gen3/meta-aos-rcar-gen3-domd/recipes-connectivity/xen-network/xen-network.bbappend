FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += " \
    file://interface-forward-systemd-networkd.conf \
"

FILES_${PN} += " \
    ${sysconfdir} \
"

do_install_append() {
    install -d ${D}${sysconfdir}/systemd/system/systemd-networkd.service.d/
    install -m 0644 ${S}/interface-forward-systemd-networkd.conf ${D}${sysconfdir}/systemd/system/systemd-networkd.service.d

    mv ${D}${sysconfdir}/systemd/network/eth0.network ${D}${sysconfdir}/systemd/network/10-eth0.network
}
