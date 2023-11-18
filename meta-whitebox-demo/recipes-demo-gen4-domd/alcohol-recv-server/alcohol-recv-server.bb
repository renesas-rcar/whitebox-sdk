DESCRIPTION = "Alcohol Sensor value receiver"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SYSTEMD_SERVICE_FILENAME = "alcohol-recv-server.service"
inherit systemd
#SYSTEMD_AUTO_ENABLE = "disable"
SYSTEMD_SERVICE_${PN} = "${SYSTEMD_SERVICE_FILENAME}"

PACKAGE_ARCH = "${MACHINE_ARCH}"

# RDEPENDS_${PN} = ""

SRC_URI = " \
    file://alcohol_recv_server.py \
    file://${SYSTEMD_SERVICE_FILENAME} \
"

S = "${WORKDIR}"
do_compile[noexec] = "1"
do_install () {
    install -d ${D}/${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/${SYSTEMD_SERVICE_FILENAME} ${D}/${systemd_unitdir}/system

    install -d ${D}/${USRBINPATH}
    install -m 0755 ${WORKDIR}/alcohol_recv_server.py ${D}/${USRBINPATH}
}

