DESCRIPTION = "Receive Packet Steering setup script with systemd service"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

RDEPENDS_${PN} = "bash"

SYSTEMD_SERVICE_FILENAME = "${BPN}.service"
SCRIPT_NAME = "${PN}.sh"

inherit systemd
#SYSTEMD_AUTO_ENABLE = "disable"
SYSTEMD_SERVICE_${PN} = "${SYSTEMD_SERVICE_FILENAME}"

PACKAGE_ARCH = "${MACHINE_ARCH}"

SRC_URI = " \
    file://${SYSTEMD_SERVICE_FILENAME} \
    file://${SCRIPT_NAME} \
"

S = "${WORKDIR}"
do_compile[noexec] = "1"
do_install () {
    install -d ${D}/${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/${SYSTEMD_SERVICE_FILENAME} ${D}/${systemd_unitdir}/system

    install -d ${D}/${USRBINPATH}
    install -m 0755 ${WORKDIR}/${SCRIPT_NAME} ${D}/${USRBINPATH}
}

