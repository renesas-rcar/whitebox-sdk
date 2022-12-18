SUMMARY = "Set of files to properly enable ICCOM functionality"
DESCRIPTION = "Set of files to properly enable ICCOM functionality"

PV = "0.1"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"
PACKAGE_ARCH = "${MACHINE_ARCH}"

RDEPENDS_${PN} = "kernel-module-uio-pdrv-genirq"

SRC_URI = "\
    file://51-uio.rules \
"

FILES_${PN} = " \
    ${sysconfdir}/udev/rules.d/51-uio.rules \
"

do_install() {
    install -d ${D}${sysconfdir}/udev/rules.d
    install -m 0644 ${WORKDIR}/51-uio.rules ${D}${sysconfdir}/udev/rules.d/
}
