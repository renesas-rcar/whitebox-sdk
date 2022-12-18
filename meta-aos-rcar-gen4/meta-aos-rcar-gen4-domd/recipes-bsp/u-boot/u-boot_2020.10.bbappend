FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_+= " \
    file://0001-net-tftp-Fix-incorrect-tftp_next_ack-on-no-OACK.patch \
"
