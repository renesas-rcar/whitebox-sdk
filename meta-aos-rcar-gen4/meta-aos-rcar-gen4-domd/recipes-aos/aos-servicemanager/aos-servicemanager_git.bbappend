FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += " \
    file://aos-cm-service.conf \
"

FILES_${PN} += " \
    ${sysconfdir}/systemd/system/aos-servicemanager.service.d/ \
"

do_install_append() {
    install -d ${D}${sysconfdir}/systemd/system/aos-servicemanager.service.d
    install -m 0644 ${WORKDIR}/aos-cm-service.conf ${D}${sysconfdir}/systemd/system/aos-servicemanager.service.d/10-aos-cm-service.conf
}
