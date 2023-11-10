FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

USE_UFS_SPIDER = " \
    file://0001-HACK-ufs-Force-enable-initilized-flag.patch \
"

SRC_URI_append_spider = " \
    ${@oe.utils.conditional("USE_UFS", "1", "${USE_UFS_SPIDER}", "", d)} \
"

