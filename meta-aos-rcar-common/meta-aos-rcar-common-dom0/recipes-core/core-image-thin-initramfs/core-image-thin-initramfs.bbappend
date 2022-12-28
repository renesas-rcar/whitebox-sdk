IMAGE_INSTALL += " \
    dom0-network \
    dom0-block-device \
    xen-tools-libxenstat \
    xen-tools-xenstat \
    app-test-utils \
"

# Aos components
IMAGE_INSTALL += " \
    aos-iamanager \
    aos-servicemanager \
"

INITRAMFS_MAXSIZE="262144"
