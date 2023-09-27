DESCRIPTION = "Script for hardware routing On/Off"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SCRIPT_FILENAME = "hw-routing.sh"
RDEPENDS_${PN} = "bash"

FILES_${PN} += " /usr/local/bin/${SCRIPT_FILENAME}"

SRC_URI = " \
    file://${SCRIPT_FILENAME} \
"

do_install() {
    install -d ${D}//usr/local/bin
    install -m 0755 ${WORKDIR}/${SCRIPT_FILENAME} ${D}/usr/local/bin
}
