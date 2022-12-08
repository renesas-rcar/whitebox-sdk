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

        echo "dhcp-host=${DOM0_MAC},dom0,${DOM0_IP},infinite" >> ${D}${sysconfdir}/dnsmasq.conf
}
