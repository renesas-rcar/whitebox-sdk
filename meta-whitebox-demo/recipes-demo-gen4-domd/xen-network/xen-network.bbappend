FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += "\
    file://rmon0.network \
    file://rmon1.network \
"

FILES_${PN} += " \
    ${sysconfdir}/systemd/network/rmon0.network \
    ${sysconfdir}/systemd/network/rmon1.network \
"

