DESCRIPTION = "Translator from Driving Simlator to COVESA CVII server"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

PACKAGE_ARCH = "${MACHINE_ARCH}"

SRC_URI += "\
    file://01-eth1.network \
"

FILES_${PN} += " \
    ${sysconfdir}/systemd/network/eth0.network \
    /etc/sysctl.conf \
"

# do_configure() nothing
do_configure[noexec] = "1"
# do_compile() nothing
do_compile[noexec] = "1"

do_install() {
    install -d ${D}/etc/systemd/network
    install -m 0644 ${WORKDIR}/01-eth1.network ${D}/etc/systemd/network

    install -d ${D}/etc
    echo "net.ipv4.ip_forward=1" > ${D}/etc/sysctl.conf
}

