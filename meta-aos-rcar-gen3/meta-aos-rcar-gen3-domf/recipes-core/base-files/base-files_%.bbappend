do_install_append() {
    # add Aos partitionss
    echo "# Aos partitions">> ${D}${sysconfdir}/fstab
    echo "/dev/aosvg/downloads /var/aos/downloads  ext4 \
        defaults,nofail,noatime,x-systemd.device-timeout=10s,x-systemd.after=var.mount  0  0" >> ${D}${sysconfdir}/fstab
    echo "/dev/aosvg/workdirs  /var/aos/workdirs   ext4 \
        defaults,nofail,noatime,x-systemd.device-timeout=10s,x-systemd.after=var.mount  0  0" >> ${D}${sysconfdir}/fstab
    echo "/dev/aosvg/storages  /var/aos/storages   ext4 \
        defaults,nofail,noatime,usrjquota=aquota.user,jqfmt=vfsv0,x-systemd.device-timeout=10s,x-systemd.after=var.mount \
        0  0" >> ${D}${sysconfdir}/fstab 
    echo "/dev/aosvg/states    /var/aos/states     ext4 \
        defaults,nofail,noatime,usrjquota=aquota.user,jqfmt=vfsv0,x-systemd.device-timeout=10s,x-systemd.after=var.mount \
        0  0" >> ${D}${sysconfdir}/fstab

    # remove /run from fstab, run is mounted in initramfs
    sed -i "\:[[:blank:]]*/run:d" ${D}${sysconfdir}/fstab
}
