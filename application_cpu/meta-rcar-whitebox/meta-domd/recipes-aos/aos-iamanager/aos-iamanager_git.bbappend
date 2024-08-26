
do_install_append() {
    if [ "${@d.getVar('USE_UFS')}" -eq "1" ]; then
        sed -i 's/mmcblk0p/sda/g' \
            ${D}${sysconfdir}/aos/aos_iamanager.cfg
    fi
}

GO_IMPORT = "github.com/aosedge/aos_iamanager"
