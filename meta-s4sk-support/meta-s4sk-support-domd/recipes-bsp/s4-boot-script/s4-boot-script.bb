SUMMARY = "Boot scripts for S4 board with Aos environment"
DESCRIPTION = "Set of U-boot scripts that automate boot process on S4 board"

PV = "0.1"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit deploy

DEPENDS += "u-boot-mkimage-native"

SRC_URI = "\
    file://boot-mmc.txt \
    file://boot-ufs.txt \
"

do_configure[noexec] = "1"

do_compile() {
    uboot-mkimage -T script -d ${WORKDIR}/boot-mmc.txt ${B}/boot-mmc.uImage
    uboot-mkimage -T script -d ${WORKDIR}/boot-ufs.txt ${B}/boot-ufs.uImage
}

do_install_append() {
    install -d ${D}/var
    install -m 0644 ${B}/boot-ufs.uImage ${D}/var/
}

do_deploy() {
    install -d ${DEPLOYDIR}
    install -m 0644 ${B}/boot-mmc.uImage ${DEPLOYDIR}/boot-mmc.uImage
    install -m 0644 ${B}/boot-ufs.uImage ${DEPLOYDIR}/boot-ufs.uImage
}

addtask deploy before do_build after do_compile

