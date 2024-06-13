do_install_append() {
    sed -i "s/device-timeout=5s/device-timeout=15s/" ${D}${sysconfdir}/fstab
}
