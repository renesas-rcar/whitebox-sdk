SUMMARY = "Internal virtual network based on Renesas R-Switch VMQ feature"

PV = "0.1"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

SRC_URI = " \
    file://vmq0.network \
    file://tsn1.network \
"

S = "${WORKDIR}"

FILES_${PN} = " \
    ${sysconfdir}/systemd/network/vmq0.network \
    ${sysconfdir}/systemd/network/tsn1.network \
"
do_install() {
    install -d ${D}${sysconfdir}/systemd/network/
    install -m 0644 ${S}/vmq0.network ${D}${sysconfdir}/systemd/network
    install -m 0644 ${S}/tsn1.network ${D}${sysconfdir}/systemd/network

}
