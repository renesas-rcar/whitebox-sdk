FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

BRANCH = "release/4.0"

SRC_URI_append = "\
    file://0002-Minor-fix.patch \
"

