do_compile_prepend() {
    sed -i -e "s/0x7c000000/0x7e000000/" ${WORKDIR}/boot-mmc.txt
    sed -i -e "s/0x7c000000/0x7e000000/" ${WORKDIR}/boot-ufs.txt
}

