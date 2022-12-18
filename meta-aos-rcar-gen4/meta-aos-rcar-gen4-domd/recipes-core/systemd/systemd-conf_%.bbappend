FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += "\
    file://journald_persist.conf \
"

do_install_append() {
    install -D -m0644 ${WORKDIR}/journald_persist.conf ${D}${systemd_unitdir}/journald.conf.d/10-${PN}.conf
}
