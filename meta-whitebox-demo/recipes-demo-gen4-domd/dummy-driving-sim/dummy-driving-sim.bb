DESCRIPTION = "Dummy Driving Simulator"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit systemd
SYSTEMD_AUTO_ENABLE = "enable"
SYSTEMD_SERVICE_FILENAME = "${PN}.service"
SYSTEMD_SERVICE_${PN} = "${SYSTEMD_SERVICE_FILENAME}"

SRC_URI_append = " \
    file://dummy-driving-sim.py \
    file://${SYSTEMD_SERVICE_FILENAME} \
"

# do_configure() nothing
do_configure[noexec] = "1"
# do_compile() nothing
do_compile[noexec] = "1"

do_install() {
    # service file
   install -d ${D}/${systemd_unitdir}/system
   install -m 0644 ${WORKDIR}/${SYSTEMD_SERVICE_FILENAME} ${D}/${systemd_unitdir}/system

   # install execution file
   install -d ${D}/${USRBINPATH}/${PN}
   install -m 0644 ${WORKDIR}/dummy-driving-sim.py ${D}/${USRBINPATH}/${PN}
}

