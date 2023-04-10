SRC_URI = "git://github.com/xen-troops/xen.git;protocol=https;branch=spider-0.8.7"
XEN_REL = "4.17"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append = " \
    file://0001-xen-cpupool-Create-different-cpupools-at-boot-time.patch \
    file://0002-arm-dom0less-assign-dom0less-guests-to-cpupools.patch \
    file://0003-xen-arm-Construct-the-P2M-pages-pool-for-guests.patch \
    file://0004-xen-Introduce-non-broken-hypercalls-for-the-paging-m.patch \
"
