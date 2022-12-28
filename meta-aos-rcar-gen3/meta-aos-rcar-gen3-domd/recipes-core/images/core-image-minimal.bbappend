# Enable RO rootfs
IMAGE_FEATURES_append = " read-only-rootfs"

IMAGE_INSTALL += " \
    xen \
    xen-tools-devd \
    xen-tools-scripts-network \
    xen-tools-scripts-block \
    xen-tools-xenstore \
    xen-network \
    dnsmasq \
    block \
"

# System components
IMAGE_INSTALL += " \
    openssh \
"

# Aos components
IMAGE_INSTALL += " \
    aos-iamanager \
    aos-servicemanager \
    aos-updatemanager \
"
