
FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append = " \
    file://nvme.service \
"

inherit systemd

SYSTEMD_SERVICE_${PN} = "nvme.service"

FILES_${PN} += " \
    ${systemd_system_unitdir} \
"

pkg_postinst_ontarget_${PN}() {
}

do_install_append() {
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/nvme.service ${D}${systemd_system_unitdir}
}

pkg_postinst_${PN}() {
    # Add aossm to /etc/hosts
    if ! grep -q 'aossm' $D${sysconfdir}/hosts ; then
        echo '127.0.0.1	aossm' >> $D${sysconfdir}/hosts
    fi
}
