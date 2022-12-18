# Enable RO rootfs
IMAGE_FEATURES_append = " read-only-rootfs"

IMAGE_INSTALL_append = " \
    xen \
    xen-tools-devd \
    xen-tools-scripts-network \
    xen-tools-scripts-block \
    xen-tools-xenstore \
    xen-network \
    dnsmasq \
    optee-os \
    block \
"

IMAGE_INSTALL_remove = "optee-client"

# System components
IMAGE_INSTALL_append = " \
    openssh \
"

# Aos components
IMAGE_INSTALL_append = " \
    aos-vis \
    aos-updatemanager \
    aos-provfinish \
"

# Aos related tasks

ROOTFS_POSTPROCESS_COMMAND += "set_board_model; set_rootfs_version; "

set_board_model() {
    install -d ${IMAGE_ROOTFS}/etc/aos

    echo "${BOARD_MODEL};${BOARD_VERSION}" > ${IMAGE_ROOTFS}/etc/aos/board_model
}

set_rootfs_version() {
    install -d ${IMAGE_ROOTFS}/etc/aos

    echo "VERSION=\"${DOMD_IMAGE_VERSION}\"" > ${IMAGE_ROOTFS}/etc/aos/version
}

