FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI_append = "\
    file://DMA_debug.cfg \
"
