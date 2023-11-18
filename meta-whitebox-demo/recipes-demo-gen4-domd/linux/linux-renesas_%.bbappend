FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

USE_UFS_SPIDER = " \
    file://0001-HACK-ufs-Force-enable-initilized-flag.patch \
"

USE_UFS_S4SK = " \
    file://0001-HACK-ufs-Force-enable-initilized-flag-for-S4SK.patch \
"

SRC_URI_append_spider = "\
    file://0001-net-ethernet-renesas-rswitch-Improve-the-performance.patch \
    ${@oe.utils.conditional("USE_UFS", "1", "${USE_UFS_SPIDER}", "", d)} \
"

SRC_URI_append_s4sk = "\
    ${@oe.utils.conditional("USE_UFS", "1", "${USE_UFS_S4SK}", "", d)} \
"


