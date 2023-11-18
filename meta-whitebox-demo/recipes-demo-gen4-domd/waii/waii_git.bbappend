FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append = "\
    file://0001-Remove-MQTT-support.patch;apply=0 \
"

do_compile_prepend() {
    cd ${S}/src/github.com/w3c/automotive-viss2
    patch -p1 < ${WORKDIR}/0001-Remove-MQTT-support.patch
}

