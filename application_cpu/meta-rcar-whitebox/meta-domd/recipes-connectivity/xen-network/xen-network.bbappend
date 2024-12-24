FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += "\
    file://interface-forward-between-domu.conf \
"

FILES_${PN} += " \
    ${sysconfdir}/systemd/system/systemd-networkd.service.d \
"

do_install_append() {
    install -d ${D}${sysconfdir}/systemd/system/systemd-networkd.service.d/
    install -m 0644 ${S}/interface-forward-between-domu.conf ${D}${sysconfdir}/systemd/system/systemd-networkd.service.d
}

