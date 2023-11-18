DESCRIPTION = "Translator from Driving Simlator to COVESA CVII server"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

PACKAGE_ARCH = "${MACHINE_ARCH}"

SRC_URI += "\
    file://00-eth0.network \
"

FILES_${PN} += " \
    ${sysconfdir}/systemd/network/eth0.network \
"

# do_configure() nothing
do_configure[noexec] = "1"
# do_compile() nothing
do_compile[noexec] = "1"

do_install() {
    install -d ${D}/etc/systemd/network
    install -m 0644 ${WORKDIR}/00-eth0.network ${D}/etc/systemd/network
}

