FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI = "git://github.com/xen-troops/xen.git;protocol=https;branch=spider-1.3.2"

SRC_URI_append = " \
    file://a.patch \
"

