DESCRIPTION = "iccom driver for R-Car S4"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://GPL-COPYING;md5=b234ee4d69f5fce4486a80fdaf4a4263"

inherit module

PR = "r0"
PV = "0.1"

SRC_URI = "git://github.com/CogentEmbedded/kernel-module-iccom.git;branch=master;protocol=https"
SRCREV = "a8c50ea65865ca72c7f53e8fcf893b6b512c3db2"

SRC_URI_append = "\
    file://0001-Cleanup-and-improve-performance.patch \
    file://0002-Fix-to-store-timeout-value-into-correct-variable.patch \
    file://0003-Fix-recv-function.patch \
    file://0004-Fix-occuring-write-operation-error-when-sending-data.patch \
"
S = "${WORKDIR}/git"

FILES_${PN} += "${includedir}/iccom_ioctl.h"

do_install_append() {
	install -d ${D}${includedir}
	install -m 0755 ${S}/iccom_ioctl.h ${D}${includedir}/
}

