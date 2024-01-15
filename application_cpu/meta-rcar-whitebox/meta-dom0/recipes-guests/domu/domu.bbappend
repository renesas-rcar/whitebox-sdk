FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += "\
    file://domu-s4sk.cfg \
    file://domu-spider.cfg \
"

do_install_prepend() {
    # Fix partition number
    sed -i 's/STORAGE_PART3/STORAGE_PART7/' ${WORKDIR}/domu-vdevices.cfg
}

