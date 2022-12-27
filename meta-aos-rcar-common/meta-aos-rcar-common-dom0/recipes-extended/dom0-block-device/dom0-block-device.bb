SUMMARY = "Attaching block device to Domain-0"

PV = "0.1"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

inherit systemd

SRC_URI = " \
    file://dom0-block-device.service \
    file://dom0-add-block-device \
    file://dom0-remove-block-device \
"

S = "${WORKDIR}"

FILES_${PN} = " \
    ${systemd_system_unitdir}/dom0-block-device.service \
    ${libdir}/xen/bin/dom0-add-block-device \
    ${libdir}/xen/bin/dom0-remove-block-device \
"

SYSTEMD_SERVICE_${PN} = "dom0-block-device.service"

RDEPENDS_${PN} = "systemd bash backend-ready"

do_install() {
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/dom0-block-device.service ${D}${systemd_system_unitdir}/

    # Install dom0-add/remove-block-device scripts
    install -d ${D}${libdir}/xen/bin
    install -m 0744 ${WORKDIR}/dom0-add-block-device ${D}${libdir}/xen/bin
    install -m 0744 ${WORKDIR}/dom0-remove-block-device ${D}${libdir}/xen/bin

}
