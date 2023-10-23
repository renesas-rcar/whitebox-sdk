FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append = " \
    file://datasources.yaml \
    file://dashboards.yaml \
    https://raw.githubusercontent.com/rfmoz/grafana-dashboards/73427563c80cb145f764462cd362c60f20358060/prometheus/node-exporter-full.json;name=json \
    https://raw.githubusercontent.com/rfmoz/grafana-dashboards/73427563c80cb145f764462cd362c60f20358060/LICENSE;name=lic \
"
SRC_URI[json.sha256sum] = "71f048d14d32d02a7812d0a14be8edca0bf252052bb81390031bae963455d782"
SRC_URI[lic.sha256sum] = "4197e22b0601b2d2cee6b98a0284fdd531b9ba5b24536a8ef40ee62eca6e1494"

CONF_FILE = "${D}/${USRBINPATH}/grafana/conf/defaults.ini"
do_install_append() {
    # Add provisioning files
    cp -f ${WORKDIR}/datasources.yaml ${D}/${USRBINPATH}/grafana/conf/provisioning/datasources/sample.yaml
    cp -f ${WORKDIR}/dashboards.yaml ${D}/${USRBINPATH}/grafana/conf/provisioning/dashboards/sample.yaml
    cp -f ${WORKDIR}/node-exporter-full.json ${D}/${USRBINPATH}/grafana/conf/provisioning/dashboards/node-exporter-full.json
    cp -f ${WORKDIR}/LICENSE ${D}/${USRBINPATH}/grafana/conf/provisioning/dashboards/LICENSE-node-exporter-full.json

    # Edit defaults.ini
    echo '[security]' >> ${CONF_FILE}
    echo 'allow_embedding = true' >> ${CONF_FILE}
    echo '[users]' >> ${CONF_FILE}
    echo 'home_page = "/d/rYdddlPWk/node-exporter-full"' >> ${CONF_FILE}
    echo '[panels]' >> ${CONF_FILE}
    echo 'disable_sanitize_html = true' >> ${CONF_FILE}
}

