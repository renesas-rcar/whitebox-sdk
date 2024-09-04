
do_install_append() {
    if [ "${@d.getVar('USE_UFS')}" -eq "1" ]; then
        sed -i 's/mmcblk0p/sda/g' \
            ${D}${sysconfdir}/aos/aos_iamanager.cfg
    fi
}

SRC_URI := "${@d.getVar('SRC_URI').replace('git@github.com/aoscloud', 'git@github.com/aosedge')}"
