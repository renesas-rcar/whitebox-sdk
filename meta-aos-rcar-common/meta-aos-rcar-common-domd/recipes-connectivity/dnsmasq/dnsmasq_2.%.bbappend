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

    if [ -z ${DOM0_IP} ]; then
        bberror "DOM0_IP is not set"
        exit 1
    fi

    if [ -z ${DHCP_NET} ]; then
        bberror "DHCP_NET is not set"
        exit 1
    fi

    # Bind dnsmasq to local host
    echo "listen-address=127.0.0.1" >> ${D}${sysconfdir}/dnsmasq.conf
    # Do not use local /etc/hosts
    echo "no-hosts" >> ${D}${sysconfdir}/dnsmasq.conf
    # Set domain
    echo "domain=${DOMAIN_NAME}" >> ${D}${sysconfdir}/dnsmasq.conf
    # Set local
    echo "local=/${DOMAIN_NAME}/" >> ${D}${sysconfdir}/dnsmasq.conf
    # DHCP range for xenbr0
    echo "dhcp-range=xenbr0,${DHCP_NET}.2,${DHCP_NET}.150,12h" >> ${D}${sysconfdir}/dnsmasq.conf
    # DHCP settings for dom0
    echo "dhcp-host=xenbr0,${DOM0_HOST_NAME},${DOM0_IP},infinite" >> ${D}${sysconfdir}/dnsmasq.conf
    # Add domd host
    echo "address=/${HOST_NAME}.${DOMAIN_NAME}/${DHCP_NET}.1" >> ${D}${sysconfdir}/dnsmasq.conf
    # Add additional interfaces
    for interface in ${DNSMASQ_INTERFACES}; do
        echo "interface=${interface}" >> ${D}${sysconfdir}/dnsmasq.conf
    done
    # Add additional DNS servers
    for server in ${DNSMASQ_SERVERS}; do
        echo "server=${server}" >> ${D}${sysconfdir}/dnsmasq.conf
    done
    # Add additional hosts
    for address in ${DNSMASQ_ADDRESSES}; do
        echo "address=${address}" >> ${D}${sysconfdir}/dnsmasq.conf
    done
}
