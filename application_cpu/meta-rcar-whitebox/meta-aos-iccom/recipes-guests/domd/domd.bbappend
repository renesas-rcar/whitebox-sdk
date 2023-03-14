FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += "\
    file://domd-set-root \
"

FILES_${PN} += " \
    ${libdir}/xen/bin/domd-set-root \
"
