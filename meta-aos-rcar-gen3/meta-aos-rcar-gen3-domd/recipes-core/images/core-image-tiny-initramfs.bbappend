COMPATIBLE_HOST = "aarch64.*-linux"

IMAGE_NAME = "initramfs-domd"

PACKAGE_INSTALL = " \
    initramfs-module-vardir \
    initramfs-module-machineid \
    initramfs-module-aosupdate \
    kernel-module-overlay \
    busybox \
"
