DESCRIPTION = "Script for pktgen"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

RDEPENDS_${PN} = "bash"

FILES_${PN} += " /usr/local/bin/pktgen_sample01_simple.sh"
FILES_${PN} += " /usr/local/bin/parameters.sh"
FILES_${PN} += " /usr/local/bin/functions.sh"

SRC_URI = " \
    file://pktgen_sample01_simple.sh \
    file://parameters.sh \
    file://functions.sh \
"

do_install() {
    install -d ${D}//usr/local/bin
    install -m 0755 ${WORKDIR}/pktgen_sample01_simple.sh ${D}/usr/local/bin
    install -m 0755 ${WORKDIR}/parameters.sh ${D}/usr/local/bin
    install -m 0755 ${WORKDIR}/functions.sh ${D}/usr/local/bin
}
