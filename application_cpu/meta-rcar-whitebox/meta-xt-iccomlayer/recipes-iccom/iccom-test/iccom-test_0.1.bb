SUMMARY="ICCOM tester"
LICENSE = "CLOSED"

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
