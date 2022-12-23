SUMMARY = "Applications to test unikernel apps"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRCREV = "032e24e427bb484195670a045f396f2dad25ba62"

S = "${WORKDIR}/git"

SRC_URI = "git://github.com/oleksiimoisieiev/unikraft-app-pool"

TARGET_CC_ARCH += "${LDFLAGS}"
BUILD_CFLAGS += "-O"

do_compile() {
         ${CC} ${BUILD_CFLAGS} ${S}/pv-tester/pv-sender.c -o ${S}/pv-tester/pv-sender
}

do_install() {
         install -d ${D}${bindir}
         install -m 0755 ${S}/pv-tester/pv-sender ${D}${bindir}
}
