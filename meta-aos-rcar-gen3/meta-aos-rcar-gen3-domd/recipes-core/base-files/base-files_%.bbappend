do_install_append() {
    # add Aos partitions
    echo "# Aos partitions">> ${D}${sysconfdir}/fstab
    echo "/dev/aosvg/workdirs  /var/aos/workdirs   ext4 \
        defaults,nofail,noatime,x-systemd.device-timeout=5s,x-systemd.after=var.mount  0  0" >> ${D}${sysconfdir}/fstab
    echo "${MAIN_NODE_ADDRESS}:/var/aos/storages      /var/aos/storages    nfs4 \
        defaults,nofail,noatime,x-systemd.automount    0  0" >> ${D}${sysconfdir}/fstab
    echo "${MAIN_NODE_ADDRESS}:/var/aos/states        /var/aos/states      nfs4 \
        defaults,nofail,noatime,x-systemd.automount    0  0" >> ${D}${sysconfdir}/fstab

    # remove /run from fstab, run is mounted in initramfs
    sed -i "\:[[:blank:]]*/run:d" ${D}${sysconfdir}/fstab
}
