FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += " \
    file://interface-forward-systemd-networkd.conf \
"

FILES_${PN} += " \
    ${sysconfdir}/systemd/system/systemd-networkd.service.d \
"

do_install_append() {
    install -d ${D}${sysconfdir}/systemd/system/systemd-networkd.service.d/
    install -m 0644 ${S}/interface-forward-systemd-networkd.conf ${D}${sysconfdir}/systemd/system/systemd-networkd.service.d
}
