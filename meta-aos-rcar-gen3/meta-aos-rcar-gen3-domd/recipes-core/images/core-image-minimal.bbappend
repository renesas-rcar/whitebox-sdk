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

ROOTFS_POSTPROCESS_COMMAND += "set_rootfs_version; create_unprovisioned_flag;"

set_rootfs_version() {
    install -d ${IMAGE_ROOTFS}/etc/aos

    echo "VERSION=\"${DOMD_IMAGE_VERSION}\"" > ${IMAGE_ROOTFS}/etc/aos/version
}

create_unprovisioned_flag() {
    install -d ${DEPLOY_DIR_IMAGE}/aos
    touch ${DEPLOY_DIR_IMAGE}/aos/.unprovisioned
}
