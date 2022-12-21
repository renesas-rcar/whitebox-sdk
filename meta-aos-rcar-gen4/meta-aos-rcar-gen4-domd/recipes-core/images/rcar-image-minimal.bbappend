# Enable RO rootfs
IMAGE_FEATURES_append = " read-only-rootfs"

IMAGE_INSTALL += " \
    pciutils \
    devmem2 \
    iccom-support \
    optee-test \
"

IMAGE_INSTALL += "iproute2 iproute2-tc tcpdump nvme-cli"

IMAGE_INSTALL += " kernel-module-nvme-core kernel-module-nvme"

IMAGE_INSTALL += " kernel-module-ixgbe"

IMAGE_INSTALL += "e2fsprogs"

# System components
IMAGE_INSTALL += " \
    openssh \
"
