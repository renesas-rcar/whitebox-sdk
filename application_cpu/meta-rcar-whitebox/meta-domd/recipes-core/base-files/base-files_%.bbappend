do_install_append() {
    # Fix docker on readnly rootfs
    echo "# Fix docker on readonly rootfs">> ${D}${sysconfdir}/fstab
    echo "/var /etc/docker  none \
        defaults,bind,nofail  0  0" >> ${D}${sysconfdir}/fstab

    # Fix timeout error for device /dev/aosvg/workdirs
    sed -i 's/5s/10s/' ${D}${sysconfdir}/fstab
}

