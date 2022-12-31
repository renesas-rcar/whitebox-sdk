# Enable RO rootfs
IMAGE_FEATURES_append = " read-only-rootfs"

IMAGE_INSTALL += " \
    pciutils \
    devmem2 \
    iccom-support \
    optee-test \
    block \
"

IMAGE_INSTALL += "iproute2 iproute2-tc tcpdump nvme-cli"

IMAGE_INSTALL += " kernel-module-nvme-core kernel-module-nvme"

IMAGE_INSTALL += " kernel-module-ixgbe"

IMAGE_INSTALL += "e2fsprogs"

# System components
IMAGE_INSTALL += " \
    openssh \
"

# Aos components
IMAGE_INSTALL += " \
    aos-vis \
    aos-iamanager \
    aos-communicationmanager \
    aos-servicemanager \
    aos-updatemanager \
"

ROOTFS_POSTPROCESS_COMMAND += "set_unit_model; set_rootfs_version; create_unprovisioned_flag;"

set_unit_model() {
    install -d ${IMAGE_ROOTFS}/etc/aos

    echo "${UNIT_MODEL};${UNIT_VERSION}" > ${IMAGE_ROOTFS}/etc/aos/unit_model
}

set_rootfs_version() {
    install -d ${IMAGE_ROOTFS}/etc/aos

    echo "VERSION=\"${DOMD_IMAGE_VERSION}\"" > ${IMAGE_ROOTFS}/etc/aos/version
}

create_unprovisioned_flag() {
    install -d ${DEPLOY_DIR_IMAGE}/aos
    touch ${DEPLOY_DIR_IMAGE}/aos/.unprovisioned
}
