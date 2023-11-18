FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

RDEPENDS_${PN} += "textfile-collector"

SYSTEMD_SERVICE_FILENAME = "node_exporter.service"
SRC_URI_append = " \
    file://${SYSTEMD_SERVICE_FILENAME} \
"

