FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

RDEPENDS_${PN} = "backend-ready"
SRC_URI += "\
    file://domu-set-root \
    file://domu.service \
    file://domu-vdevices.cfg \
"

FILES_${PN} += " \
    ${libdir}/xen/bin/domu-set-root \
"

# It is used a lot in the do_install, so variable will be handy
CFG_FILE="${D}${sysconfdir}/xen/domu.cfg"

do_install_append() {
    cat ${WORKDIR}/domu-vdevices.cfg >> ${CFG_FILE}

    # Install domu-set-root script
    install -d ${D}${libdir}/xen/bin
    install -m 0744 ${WORKDIR}/domu-set-root ${D}${libdir}/xen/bin

    # Call domu-set-root script
    echo "[Service]" >> ${D}${systemd_unitdir}/system/domu.service
    echo "ExecStartPre=${libdir}/xen/bin/domu-set-root" >> ${D}${systemd_unitdir}/system/domu.service
}
