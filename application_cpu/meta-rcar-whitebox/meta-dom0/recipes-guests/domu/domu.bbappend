FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

do_install_prepend() {
    # Fix partition number
    sed -i 's/STORAGE_PART3/STORAGE_PART7/' ${WORKDIR}/domu-vdevices.cfg
}

