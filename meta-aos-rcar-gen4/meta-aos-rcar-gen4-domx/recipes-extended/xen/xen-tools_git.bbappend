require xen-source.inc

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += " \
    file://xenpcid-xenstore.conf \
"

PACKAGES_append = "\
    ${PN}-test \
    ${PN}-pcid \
"

FILES_${PN}-test = "\
    ${libdir}/xen/bin/test-xenstore \
    ${libdir}/xen/bin/test-resource \
"

FILES_${PN}-pcid = "\
    ${systemd_unitdir}/system/xenpcid.service \
    ${systemd_unitdir}/system/xenpcid.service.d/xenpcid-xenstore.conf \
"

SYSTEMD_SERVICE_${PN}-pcid = "xenpcid.service"

SYSTEMD_PACKAGES += "${PN}-pcid"

do_install_append() {
    install -d ${D}${systemd_unitdir}/system/xenpcid.service.d/
    install -m 0744 ${WORKDIR}/xenpcid-xenstore.conf ${D}${systemd_unitdir}/system/xenpcid.service.d
}
