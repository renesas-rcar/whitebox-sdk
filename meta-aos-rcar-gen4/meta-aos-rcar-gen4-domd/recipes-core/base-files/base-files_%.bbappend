do_install_append() {
    # meta-renesas does strange things with fstab file to fix own problems
    # with NFS. We don't have such problems, so we need to revert some changes
    # made by Renesas. Namely, we want /var/volatile to be owned by root.
    sed -i "s/uid=65534,gid=65534/defaults/" ${D}${sysconfdir}/fstab

    # add Aos partitions
    echo "# Aos partitions">> ${D}${sysconfdir}/fstab
    echo "/dev/aosvg/downloads /var/aos/downloads  ext4 \
        defaults,nofail,noatime,x-systemd.device-timeout=5s,x-systemd.after=var.mount  0  0" >> ${D}${sysconfdir}/fstab
    echo "/dev/aosvg/workdirs  /var/aos/workdirs   ext4 \
        defaults,nofail,noatime,x-systemd.device-timeout=5s,x-systemd.after=var.mount  0  0" >> ${D}${sysconfdir}/fstab
    echo "/dev/aosvg/storages  /var/aos/storages   ext4 \
        defaults,nofail,noatime,usrjquota=aquota.user,jqfmt=vfsv0,x-systemd.device-timeout=5s,x-systemd.after=var.mount \
        0  0" >> ${D}${sysconfdir}/fstab 
    echo "/dev/aosvg/states    /var/aos/states     ext4 \
        defaults,nofail,noatime,usrjquota=aquota.user,jqfmt=vfsv0,x-systemd.device-timeout=5s,x-systemd.after=var.mount \
        0  0" >> ${D}${sysconfdir}/fstab

    # remove /run from fstab, run is mounted in initramfs
    sed -i "\:[[:blank:]]*/run:d" ${D}${sysconfdir}/fstab
}
