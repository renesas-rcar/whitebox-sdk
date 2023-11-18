FILESEXTRAPATHS_append = "${TOPDIR}/../../../../../prebuilt_gsx/domd:"

LIC_FILES_CHKSUM = "file://GPL-COPYING;md5=b234ee4d69f5fce4486a80fdaf4a4263"

EXTRA_OEMAKE_append = " \
    ${@bb.utils.contains('XT_GUEST_INSTALL', 'doma', '', 'EXCLUDE_FENCE_SYNC_SUPPORT:=1', d)} \
    PVRSRV_VZ_NUM_OSID=${XT_PVR_NUM_OSID} \
"

python () {
    if d.getVar('XT_PREBUILT_GSX_DIR', True):
        # We use prebuilt package provided by user
        d.appendVar('FILESEXTRAPATHS', '${XT_PREBUILT_GSX_DIR}/${XT_DOM_NAME}:')
    else:
        # We prepare package by gles-km-prebuilt
        d.appendVar('FILESEXTRAPATHS', '${DEPLOY_DIR_IMAGE}/prebuilt/${XT_DOM_NAME}:')
        d.appendVarFlag('do_fetch', 'depends', ' gles-km-compile:do_deploy ')
}

