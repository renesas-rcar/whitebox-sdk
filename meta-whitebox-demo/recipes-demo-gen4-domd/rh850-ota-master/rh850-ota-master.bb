DESCRIPTION = "rh850-ota-master"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

RDEPENDS_rh850-ota-master = "bash"

BINARY_NAME = "HostApp_final_v2.zip"
SYSTEMD_SERVICE_FILENAME = "rh850-ota-master.service"
SYSTEMD_ENVIRONMENT_FILENAME = "RH850-OTA-MASTER.config"

inherit systemd
SYSTEMD_AUTO_ENABLE = "enable"
SYSTEMD_SERVICE_${PN} = "${SYSTEMD_SERVICE_FILENAME}"

SRC_URI = " \
    file://${BINARY_NAME} \
    file://${SYSTEMD_SERVICE_FILENAME} \
    file://${SYSTEMD_ENVIRONMENT_FILENAME} \
    file://rh850-ota-target.service \
"
FILES_${PN} += "/var/*"
FILES_${PN} += " ${systemd_unitdir}/system/rh850-ota-target.service"

S = "${WORKDIR}"
B = "${S}/HostApp_final_v2"

TARGET_CC_ARCH += "${LDFLAGS}"
do_compile () {
    cd ${B}
    oe_runmake
}

do_install () {
    install -d ${D}/${USRBINPATH}
    install -m 0755 ${B}/${PN} ${D}/${USRBINPATH}
    install -m 0755 ${B}/rh850-ota-test ${D}/${USRBINPATH}
    install -m 0755 ${B}/rh850-ota-target ${D}/${USRBINPATH}
    install -d ${D}/${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/${SYSTEMD_SERVICE_FILENAME} ${D}/${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/rh850-ota-target.service ${D}/${systemd_unitdir}/system
    install -d ${D}/var
    install -m 0644 ${WORKDIR}/${SYSTEMD_ENVIRONMENT_FILENAME} ${D}/var
}

