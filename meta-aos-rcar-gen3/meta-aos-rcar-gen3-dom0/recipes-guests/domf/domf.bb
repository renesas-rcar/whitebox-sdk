SUMMARY = "Set of files to run a generic guest domain"
DESCRIPTION = "A config file, kernel, dtb and scripts for a guest domain"

PV = "0.1"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

inherit externalsrc systemd

EXTERNALSRC_SYMLINKS = ""

SRC_URI = " \
    file://domf.cfg \
    file://domf.service \
    file://domf-set-root \
"

FILES_${PN} = " \
    ${sysconfdir}/xen/domf.cfg \
    ${libdir}/xen/boot/linux-domf \
    ${libdir}/xen/boot/initramfs-domf \
    ${libdir}/xen/bin/domf-set-root \
    ${systemd_system_unitdir}/domf.service \
"

SYSTEMD_SERVICE_${PN} = "domf.service"

do_install() {
    install -d ${D}${sysconfdir}/xen
    install -d ${D}${libdir}/xen/boot
    install -m 0644 ${WORKDIR}/domf.cfg ${D}${sysconfdir}/xen
    install -m 0644 ${S}/Image ${D}${libdir}/xen/boot/linux-domf

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/domf.service ${D}${systemd_system_unitdir}

    install -d ${D}${libdir}/xen/bin
    install -m 0744 ${WORKDIR}/domf-set-root ${D}${libdir}/xen/bin

    # Install domf initramfs
    install -m 0644 ${S}/initramfs-domf.rootfs.cpio.gz ${D}${libdir}/xen/boot/initramfs-domf
}
