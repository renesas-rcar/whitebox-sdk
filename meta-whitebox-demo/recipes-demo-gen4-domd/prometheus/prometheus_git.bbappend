FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

CONF_FILE = "${D}/${USRBINPATH}/${PN}/prometheus.yml"
do_install_append() {
    # Change default config
    sed -i "s/node/S4 node/" ${CONF_FILE}
    sed -i "s/scrape_interval: 1s/scrape_interval: 5s/" ${CONF_FILE}

    # Additional node
    echo '  - job_name: "H3 node"' >> ${CONF_FILE}
    echo '    scrape_interval: 5s' >> ${CONF_FILE}
    echo '    static_configs:' >> ${CONF_FILE}
    echo '    - targets: ["192.168.1.111:9100"]' >> ${CONF_FILE}
    echo '' >> ${CONF_FILE}
}

