FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += " \
    file://misc.conf \
"

FILES_${PN} += " \
    ${sysconfdir}/tmpfiles.d/misc.conf \
"

do_install_append() {
        install -d ${D}${sysconfdir}/tmpfiles.d
        install -m 0644 ${WORKDIR}/misc.conf ${D}${sysconfdir}/tmpfiles.d

        if [ -z ${DOM0_MAC} ]; then
            bberror "DOM0_MAC is not set"
            exit 1
        fi

        if [ -z ${DOM0_IP} ]; then
            bberror "DOM0_IP is not set"
            exit 1
        fi

        if [ -z ${DHCP_NET} ]; then
            bberror "DHCP_NET is not set"
            exit 1
        fi

        echo "listen-address=127.0.0.1" >> ${D}${sysconfdir}/dnsmasq.conf
        echo "dhcp-host=${DOM0_MAC},${DOM0_NODE_ID},${DOM0_IP},infinite" >> ${D}${sysconfdir}/dnsmasq.conf
        sed -i "s/192.168.0/${DHCP_NET}/g" ${D}${sysconfdir}/dnsmasq.conf
}
