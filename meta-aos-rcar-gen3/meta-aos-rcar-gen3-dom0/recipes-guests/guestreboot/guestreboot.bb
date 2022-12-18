DESCRIPTION = "Performs system reboot by guest domain request"

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = " \
    file://guestreboot.sh \
    file://guestreboot@.service \
"

S = "${WORKDIR}"

inherit systemd

FILES_${PN} = " \
    ${systemd_system_unitdir} \
    ${bindir} \
"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${S}/guestreboot.sh ${D}${bindir}

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${S}/guestreboot@.service ${D}${systemd_system_unitdir}
}
