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
    install -d ${D}${sysconfdir}/systemd/system/systemd-networkd.service.d/
    install -m 0644 ${S}/interface-forward-systemd-networkd.conf ${D}${sysconfdir}/systemd/system/systemd-networkd.service.d

    # Add route to gen3 for tsn1
    echo "[Route]"  >> ${D}${sysconfdir}/systemd/network/tsn1.network
    echo "Gateway=10.0.0.2" >> ${D}${sysconfdir}/systemd/network/tsn1.network
    echo "Destination=${GEN3_DHCP_NET}.0/24" >> ${D}${sysconfdir}/systemd/network/tsn1.network
}
