FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append = " \
    file://simple-video-streaming.service \
    file://0001-WIP-For-demo.patch \
    file://0002-WIP.patch \
"

BRANCH = "main"
SRCREV = "3f5ad40c60fd5ceb45af0145f4abf977cd0c5a85"

