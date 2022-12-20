# for uboot-mkimage
DEPENDS += "u-boot-mkimage-native"

generate_uboot_image() {
    uboot-mkimage -A arm64 -O linux -T ramdisk -C gzip -n "uInitramfs" \
        -d ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.cpio.gz  ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.cpio.gz.uInitramfs
    ln -sfr  ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.cpio.gz.uInitramfs ${DEPLOY_DIR_IMAGE}/uInitramfs
}

IMAGE_POSTPROCESS_COMMAND += " generate_uboot_image; "

IMAGE_ROOTFS_SIZE = "65535"

