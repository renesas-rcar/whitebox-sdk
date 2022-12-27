do_install_append() {
    if [ -z ${DHCP_NET} ]; then
        bberror "DHCP_NET is not set"
        exit 1
    fi

    sed -i "s/192.168.0/${DHCP_NET}/g" ${D}${sysconfdir}/systemd/network/xenbr0.network

    if [ -f ${D}${sysconfdir}/systemd/system/systemd-networkd.service.d/port-forward-systemd-networkd.conf ]; then
        sed -i "s/192.168.0/${DHCP_NET}/g" ${D}${sysconfdir}/systemd/system/systemd-networkd.service.d/port-forward-systemd-networkd.conf
    fi
}
