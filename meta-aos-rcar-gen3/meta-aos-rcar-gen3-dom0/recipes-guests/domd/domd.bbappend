FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += " \
    file://domd-set-root \
    file://domd-override.conf \
"

FILES_${PN} += " \
    ${libdir}/xen/bin/domd-set-root \
    ${libdir}/xen/boot/initramfs-domd \
    ${sysconfdir}/systemd/system/domd.service.d/ \
"

RDEPENDS_${PN} += " \
    guestreboot \
"

do_install_append() {
    if ${@bb.utils.contains('DISTRO_FEATURES', 'virtio', 'true', 'false', d)}; then
        # Increase XT page pool
        sed -i 's/xt_page_pool=67108864/xt_page_pool=603979776/' \
        ${D}${sysconfdir}/xen/domd.cfg
    fi

    # Install domd-set-root script
    install -d ${D}${libdir}/xen/bin
    install -m 0744 ${WORKDIR}/domd-set-root ${D}${libdir}/xen/bin

    # Override domd.service configuration
    install -d ${D}${sysconfdir}/systemd/system/domd.service.d
    install -m 0644 ${WORKDIR}/domd-override.conf ${D}${sysconfdir}/systemd/system/domd.service.d

    # Install domd initramfs
    install -m 0644 ${S}/initramfs-domd.rootfs.cpio.gz ${D}${libdir}/xen/boot/initramfs-domd
}
