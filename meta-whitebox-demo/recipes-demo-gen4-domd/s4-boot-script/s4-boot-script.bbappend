
do_compile_prepend() {
    sed -i -e 's/mmc/scsi/g' \
        ${WORKDIR}/boot-ufs.txt
}

