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

IMAGE_POSTPROCESS_COMMAND += "set_image_version; create_unprovisioned_flag;"

set_image_version() {
    install -d ${DEPLOY_DIR_IMAGE}/aos
    echo "VERSION=\"${DOM0_IMAGE_VERSION}\"" > ${DEPLOY_DIR_IMAGE}/aos/version
}

create_unprovisioned_flag() {
    install -d ${DEPLOY_DIR_IMAGE}/aos
    touch ${DEPLOY_DIR_IMAGE}/aos/.unprovisioned
}
