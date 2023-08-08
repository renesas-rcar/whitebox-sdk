DESCRIPTION = "Script for copying disk image from SD card to UFS"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SCRIPT_FILENAME = "ufs-duplication-script.sh"
RDEPENDS_${PN} = "bash"

FILES_${PN} += " ${SCRIPT_FILENAME}"

SRC_URI = " \
    file://${SCRIPT_FILENAME} \
"

S = "${WORKDIR}"
do_compile[noexec] = "1"
do_install () {
    install -d ${D}/${USRBINPATH}
    install -m 0755 ${WORKDIR}/${SCRIPT_FILENAME} ${D}/${USRBINPATH}
}

