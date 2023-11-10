FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SYSTEMD_PACKAGES = "snort-tsn0 snort-tsn1 "
SYSTEMD_SERVICE:snort-tsn0 = "snort-tsn0.service"
SYSTEMD_SERVICE:snort-tsn1 = "snort-tsn1.service"
SYSTEMD_SERVICE:snort-tsn2 = ""

do_install:append() {
    rm -f ${D}${systemd_unitdir}/system/snort-tsn2.service
}

