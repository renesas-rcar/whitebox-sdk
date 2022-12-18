FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

BRANCH = "v5.10.41/rcar-5.1.7.rc5"
SRCREV = "${AUTOREV}"
LINUX_VERSION = "5.10.41"

SRC_URI = "\
    git://github.com/renesas-rcar/linux-bsp.git;branch=${BRANCH} \
    file://defconfig \
"
