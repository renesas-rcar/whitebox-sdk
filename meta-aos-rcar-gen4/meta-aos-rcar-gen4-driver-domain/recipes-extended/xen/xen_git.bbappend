FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append_spider = " \
    file://early_printk_spider.cfg \
"

do_configure_append() {
    # merge configuration fragments manually using kconfig's native facilities
    ${S}/xen/tools/kconfig/merge_config.sh -m -O ${B}/xen ${B}/xen/.config ${WORKDIR}/*.cfg
}
