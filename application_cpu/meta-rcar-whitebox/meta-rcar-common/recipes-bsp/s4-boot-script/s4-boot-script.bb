SUMMARY = "Boot scripts for S4 board with Aos environment"
DESCRIPTION = "Set of U-boot scripts that automate boot process on S4 board"

PV = "0.1"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

inherit deploy

DEPENDS += "u-boot-mkimage-native"

SRC_URI = "\
    file://boot-mmc.txt \
"

do_configure[noexec] = "1"
do_install[noexec] = "1"

do_compile() {
    uboot-mkimage -T script -d ${WORKDIR}/boot-mmc.txt ${B}/boot-mmc.uImage
}

do_deploy() {
    install -d ${DEPLOYDIR}
    install -m 0644 ${B}/boot-mmc.uImage ${DEPLOYDIR}/boot-mmc.uImage
}

addtask deploy before do_build after do_compile

