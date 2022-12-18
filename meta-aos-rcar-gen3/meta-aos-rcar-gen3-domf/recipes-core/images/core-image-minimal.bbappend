# Enable RO rootfs
IMAGE_FEATURES_append = " read-only-rootfs"

IMAGE_INSTALL_append = " \
    bash \
    domu-network \
"

# System components
IMAGE_INSTALL_append = " \
    openssh \
"

# Aos components
IMAGE_INSTALL_append = " \
    aos-iamanager \
    aos-communicationmanager \
    aos-servicemanager \
    aos-updatemanager \
"

# Aos related tasks

ROOTFS_POSTPROCESS_COMMAND += "set_rootfs_version; "

set_rootfs_version() {
    install -d ${IMAGE_ROOTFS}/etc/aos

    echo "VERSION=\"${DOMF_IMAGE_VERSION}\"" > ${IMAGE_ROOTFS}/etc/aos/version
}
