IMAGE_INSTALL += " \
    pciutils \
    devmem2 \
    iccom-support \
    optee-test \
    vmq-network \
"

IMAGE_INSTALL += "kernel-module-nvme"
IMAGE_INSTALL += "kernel-module-nvme-core"

IMAGE_INSTALL += "kernel-module-ixgbevf"

IMAGE_INSTALL += "e2fsprogs"
IMAGE_INSTALL += "iproute2 iproute2-tc"
