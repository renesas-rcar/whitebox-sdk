FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += " \
    file://aos-service@.service \
"

RDEPENDS_${PN}_remove = " \
    quota \
    cni \
    aos-firewall \
    aos-dnsname \
    python3 \
    python3-core \
    packagegroup-core-nfs-client \
"

RRECOMMENDS_${PN} = " \
    kernel-module-overlay \
"

do_install_append() {
    install -m 0644 ${WORKDIR}/aos-service@.service ${D}${systemd_system_unitdir}
}