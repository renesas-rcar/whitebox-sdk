FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += "\
    file://systemd-networkd-wait-online.conf \
    file://interface-forward-systemd-networkd.conf \
    file://tsn0.network \
    file://tsn1.network \
    file://vmq0.network \
"

FILES_${PN} += " \
    ${sysconfdir}/systemd/network/tsn0.network \
    ${sysconfdir}/systemd/network/tsn1.network \
    ${sysconfdir}/systemd/network/vmq0.network \
    ${sysconfdir}/systemd/system/systemd-networkd.service.d \
"

do_install_append() {
    if [ -f ${D}${sysconfdir}/systemd/system/systemd-networkd.service.d/port-forward-systemd-networkd.conf ]; then
        sed -i "s/eth0/tsn0/g" ${D}${sysconfdir}/systemd/system/systemd-networkd.service.d/port-forward-systemd-networkd.conf
    fi

    install -d ${D}${sysconfdir}/systemd/system/systemd-networkd.service.d/
    install -m 0644 ${S}/interface-forward-systemd-networkd.conf ${D}${sysconfdir}/systemd/system/systemd-networkd.service.d
}
