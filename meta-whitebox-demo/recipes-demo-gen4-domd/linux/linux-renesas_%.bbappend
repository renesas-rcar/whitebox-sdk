FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append_spider = "\
    file://0001-net-ethernet-renesas-rswitch-Improve-the-performance.patch \
"

