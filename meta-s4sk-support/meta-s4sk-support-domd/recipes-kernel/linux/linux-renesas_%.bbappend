FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

RENESAS_BSP_URL = "git://github.com/renesas-rcar/linux-xen.git"
BRANCH = "v5.10.41/rcar-5.1.7.rc11-xt"
SRCREV = "33c9c4268e83508c68567fac3ff7a6f8b53f1868"

USE_UFS_S4SK = " \
    file://0001-HACK-ufs-Force-enable-initilized-flag-for-S4SK.patch \
"

SRC_URI_append_s4sk = " \
    ${@oe.utils.conditional("USE_UFS", "1", "${USE_UFS_S4SK}", "", d)} \
"

