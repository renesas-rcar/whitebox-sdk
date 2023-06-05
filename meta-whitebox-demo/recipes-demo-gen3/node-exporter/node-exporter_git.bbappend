FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SYSTEMD_SERVICE_FILENAME = "node_exporter.service"
SRC_URI_append = " \
    file://${SYSTEMD_SERVICE_FILENAME} \
"

