FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
    file://0001-xen-pvcalls-back-fix-permanently-masked-event-channe.patch \
    file://0001-xen-pvcalls-free-active-map-buffer-on-pvcalls_front_.patch \
"
