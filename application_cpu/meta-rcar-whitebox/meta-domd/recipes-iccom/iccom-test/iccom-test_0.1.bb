SUMMARY="ICCOM tester"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

SRC_URI	= "file://*"

inherit cmake

S = "${WORKDIR}"

DEPENDS += "iccom-lib"

FILES_${PN} += "${includedir}/iccom.h \
		${libdir}/libiccom.a"

do_install() {
	install -d ${D}${bindir}
	install -m 0755 ${S}/build/iccom-test ${D}${bindir}
}
