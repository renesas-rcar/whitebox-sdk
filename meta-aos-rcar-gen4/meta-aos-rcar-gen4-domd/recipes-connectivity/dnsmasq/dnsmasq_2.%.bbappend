do_install_append() {
        echo "address=/wwwivi/${DHCP_NET}.1" >> ${D}${sysconfdir}/dnsmasq.conf
}
