RDEPENDS_${PN} += "\
    ${@bb.utils.contains("AOS_RUNNER", "runx", " runx", "${AOS_RUNNER}", d)} \
"
