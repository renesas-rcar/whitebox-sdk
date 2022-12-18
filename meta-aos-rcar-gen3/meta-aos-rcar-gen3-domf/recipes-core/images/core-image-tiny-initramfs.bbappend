COMPATIBLE_HOST = "aarch64.*-linux"

IMAGE_NAME = "initramfs-domf"

PACKAGE_INSTALL = " \
    initramfs-module-rundir \
    initramfs-module-vardir \
    initramfs-module-machineid \
    initramfs-module-udev \
    initramfs-module-lvm \
    initramfs-module-opendisk \
    initramfs-module-aosupdate \
    kernel-module-overlay \
    busybox \
    optee-client \
    optee-pkcs11-ta \
    lvm2 \
"
