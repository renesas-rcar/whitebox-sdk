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

# System components # Dropbear is already contained
# IMAGE_INSTALL += " \
#     openssh \
# "

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

### For Incremental Update

# # inherit metadata-generator bundle-generator rootfs-image-generator
# inherit rootfs-image-generator
# 
# # Variables
# BUNDLE_DIR ?= "${DEPLOY_DIR}/update"
# BUNDLE_FILE ?= "${UNIT_MODEL}-${UNIT_VERSION}-${DOMAIN_NAME}-${BUNDLE_IMAGE_VERSION}.tar"
# BUNDLE_DOM0_TYPE ?= ""
# BUNDLE_DOMD_TYPE ?= ""
# BUNDLE_RH840_TYPE ?= ""
# BUNDLE_OSTREE_REPO ?= "${DEPLOY_DIR}/update/repo"
# DOMD_DEPLOY_DIR = "${EXTERNALSRC_pn-domd}"
# # Dependencies
# do_create_bundle[depends] += "core-image-thin-initramfs:do_${BB_DEFAULT_TASK}"
# do_create_bundle[cleandirs] = "${BUNDLE_WORK_DIR}"
# do_create_bundle[dirs] = "${BUNDLE_DIR}"
# do_create_dom0_image[cleandirs] = "${WORKDIR}/rootfs_dom0"
# do_prepare_rootfs[cleandirs] = "${WORKDIR}/rootfs_domx"
# # Configuration
# BUNDLE_DOM0_ID = "${UNIT_MODEL}-${UNIT_VERSION}-${DOMAIN_NAME}-dom0"
# BUNDLE_DOMD_ID = "${UNIT_MODEL}-${UNIT_VERSION}-${DOMAIN_NAME}-domd"
# BUNDLE_RH850_ID = "${UNIT_MODEL}-${UNIT_VERSION}-${DOMAIN_NAME}-rh850"
# BUNDLE_DOM0_DESC = "Dom0 image"
# BUNDLE_DOMD_DESC = "DomD image"
# BUNDLE_RH850_DESC = "RH850 image"
# ROOTFS_IMAGE_DIR = "${BUNDLE_WORK_DIR}"
# ROOTFS_EXCLUDE_FILES = "var/*"
# DOM0_IMAGE_FILE = "${BUNDLE_DOM0_ID}-${BUNDLE_DOM0_TYPE}-${DOM0_IMAGE_VERSION}.gz"
# DOMD_IMAGE_FILE = "${BUNDLE_DOMD_ID}-${BUNDLE_DOMD_TYPE}-${DOMD_IMAGE_VERSION}.squashfs"
# RH850_IMAGE_FILE = "${BUNDLE_RH850_ID}-${BUNDLE_RH850_TYPE}-${RH850_IMAGE_VERSION}.gz"
# DOM0_PART_SIZE = "128"
# DOM0_PART_LABEL = "boot"
# 
# 
# do_prepare_rootfs() {
#     if [ -z ${ROOTFS_IMAGE_TYPE} ]; then
#         exit 0
#     fi
#     tar -C ${WORKDIR}/rootfs_domx -xjf ${ROOTFS_SOURCE_ARCHIVE}
# }
# 
# do_create_ostree_ref() {
#     if [ -z ${ROOTFS_IMAGE_TYPE} ] || [ ${ROOTFS_IMAGE_TYPE} = "none" ]; then
#         exit 0
#     fi
# 
#     if [ ! -d ${ROOTFS_OSTREE_REPO}/refs ]; then
#         init_ostree_repo
#     fi
#     if ${@bb.utils.contains('DISTRO_FEATURES', 'selinux', 'true', 'false', d)}; then
#         ROOTFS_FULL_PATH=$(realpath ${ROOTFS_SOURCE_DIR})
#         setfiles -m -r ${ROOTFS_FULL_PATH} ${ROOTFS_FULL_PATH}/etc/selinux/aos/contexts/files/file_contexts ${ROOTFS_FULL_PATH}
#     fi
#     ostree_commit
# }
# 
# python do_create_ostree() {
#     d.setVar("ROOTFS_OSTREE_REPO", os.path.join(d.getVar("BUNDLE_OSTREE_REPO"), d.getVar("BUNDLE_DOMD_ID")))
#     d.setVar("ROOTFS_IMAGE_TYPE", d.getVar("BUNDLE_DOMD_TYPE"))
#     d.setVar("ROOTFS_IMAGE_VERSION", d.getVar("DOMD_IMAGE_VERSION"))
#     d.setVar("ROOTFS_REF_VERSION", d.getVar("DOMD_REF_VERSION"))
#     d.setVar("ROOTFS_IMAGE_FILE", d.getVar("DOMD_IMAGE_FILE"))
#     d.setVar("ROOTFS_SOURCE_DIR", os.path.join(d.getVar("WORKDIR"),"rootfs_domx"))
#     d.setVar("ROOTFS_SOURCE_ARCHIVE", os.path.join(d.getVar("DOMD_DEPLOY_DIR"), \
#         "{}-{}.tar.bz2".format(d.getVar("PN"), d.getVar("MACHINE"))))
# 
#     bb.build.exec_func("do_prepare_rootfs", d)
#     bb.build.exec_func("do_create_ostree_ref", d)
# }
# addtask create_ostree after do_compile before do_build
