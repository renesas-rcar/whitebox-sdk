FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

do_install_append() {
    if ${@bb.utils.contains('DISTRO_FEATURES', 'virtio', 'true', 'false', d)}; then
        # Increase XT page pool
        sed -i 's/xt_page_pool=67108864/xt_page_pool=603979776/' \
        ${D}${sysconfdir}/xen/domd.cfg
    fi
}
