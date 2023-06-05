DESCRIPTION = "Autostart service file installer for chromium"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

PACKAGE_ARCH = "${MACHINE_ARCH}"
RDEPENDS_${PN} = "bash"

inherit systemd
SYSTEMD_AUTO_ENABLE = "enable"
SYSTEMD_SERVICE_FILENAME = "autostart-browser.service"
SYSTEMD_SERVICE_${PN} = "${SYSTEMD_SERVICE_FILENAME}"
SYSTEMD_ENVIRONMENT_FILENAME = "autostart-browser.config"
FILES_${PN} += "/var/${SYSTEMD_ENVIRONMENT_FILENAME}"

SRC_URI_append = " \
    file://${SYSTEMD_SERVICE_FILENAME} \
    file://${SYSTEMD_ENVIRONMENT_FILENAME} \
"

# do_configure() nothing
do_configure[noexec] = "1"
# do_compile() nothing
do_compile[noexec] = "1"

do_install () {
    # service file
    install -d ${D}/${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/${SYSTEMD_SERVICE_FILENAME} ${D}/${systemd_unitdir}/system

    # Copt config file
    install -d ${D}/var
    install -m 0644 ${WORKDIR}/${SYSTEMD_ENVIRONMENT_FILENAME} ${D}/var
}

