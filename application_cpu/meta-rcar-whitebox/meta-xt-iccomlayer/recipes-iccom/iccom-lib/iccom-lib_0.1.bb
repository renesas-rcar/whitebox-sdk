SUMMARY="ICCOM userspace library"
LICENSE = "CLOSED"

SRC_URI	= "file://*"

inherit cmake

S = "${WORKDIR}"

DEPENDS += "iccom"

FILES_${PN} += "${includedir}/iccom_ioctl.h \
		${libdir}/libiccom.a \
		${includedir}/iccom.h"

do_install() {
	install -d ${D}${libdir}
	install -d ${D}${includedir}

	install -m 0755 ${WORKDIR}/build/libiccom.a ${D}${libdir}/libiccom.a
	install -m 0755 ${WORKDIR}/iccom.h ${D}${includedir}/iccom.h
}

ALLOW_EMPTY_${PN} = "1"
