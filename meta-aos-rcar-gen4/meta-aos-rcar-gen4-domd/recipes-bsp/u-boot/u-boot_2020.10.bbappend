FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

BRANCH = "v2020.10/rcar-5.1.1.rc2"
SRCREV = "3ec5cec05015d8b290a8d390b0246e1df3865199"

SRC_URI_+= " \
    file://0001-net-tftp-Fix-incorrect-tftp_next_ack-on-no-OACK.patch \
"
