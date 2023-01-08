IMAGE_NAME = "initramfs-domd"

AOS_INITRAMFS_SCRIPTS += " \
    initramfs-module-lvm \
    initramfs-module-nfsrootfs \
    initramfs-module-opendisk \
    initramfs-module-rundir \
    optee-pkcs11-ta \
    optee-client \
    lvm2 \
"
