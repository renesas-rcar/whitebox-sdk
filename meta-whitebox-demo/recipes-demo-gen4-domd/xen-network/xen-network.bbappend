FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += "\
    file://tsn0.network \
    file://tsn1.network \
    file://rmon0.network \
    file://rmon1.network \
"

FILES_${PN} += " \
    ${sysconfdir}/systemd/network/tsn0.network \
    ${sysconfdir}/systemd/network/tsn1.network \
    ${sysconfdir}/systemd/network/rmon0.network \
    ${sysconfdir}/systemd/network/rmon1.network \
"

# do_install_append() {
#     install -d ${D}${sysconfdir}/systemd/system/systemd-networkd.service.d/
#     install -m 0644 ${S}/interface-forward-systemd-networkd.conf ${D}${sysconfdir}/systemd/system/systemd-networkd.service.d
# }

