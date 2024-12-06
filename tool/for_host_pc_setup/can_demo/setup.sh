#!/bin/bash -eu

GRAFANA_VER=11.1.0
PROMETHEUS_VER=2.53.0
NODEEXPORTER_VER=1.8.1

SCRIPT_DIR=$(cd `dirname $` && pwd)
cd $SCRIPT_DIR

which cargo > /dev/null
if [[ "$?" -ne 0 ]]; then
    echo "Please install rust by using following command"
    echo "    curl https://sh.rustup.rs -sSf | sh"
fi
cargo install --locked --git https://github.com/asciinema/asciinema

wget -c https://dl.grafana.com/oss/release/grafana-${GRAFANA_VER}.linux-amd64.tar.gz
wget -c https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VER}/prometheus-${PROMETHEUS_VER}.linux-amd64.tar.gz
wget -c https://github.com/prometheus/node_exporter/releases/download/v${NODEEXPORTER_VER}/node_exporter-${NODEEXPORTER_VER}.linux-amd64.tar.gz
wget -c https://github.com/rfmoz/grafana-dashboards/raw/master/prometheus/node-exporter-full.json

tar xf grafana-${GRAFANA_VER}.linux-amd64.tar.gz
tar xf prometheus-${PROMETHEUS_VER}.linux-amd64.tar.gz
tar xf node_exporter-${NODEEXPORTER_VER}.linux-amd64.tar.gz

unlink ./grafana || true
unlink ./prometheus || true
unlink ./node_exporter || true

ln -sf grafana-v${GRAFANA_VER} grafana
ln -sf prometheus-${PROMETHEUS_VER}.linux-amd64 prometheus
ln -sf node_exporter-${NODEEXPORTER_VER}.linux-amd64 node_exporter

cp -f node-exporter-full.json -t ./grafana/conf/provisioning/dashboards/
cp -f can_demo_dashboard_single.json -t ./grafana/conf/provisioning/dashboards/
cp -f can_demo_dashboard_dual.json -t ./grafana/conf/provisioning/dashboards/

pip3 install python-can

##########
# Config #
##########
cd $SCRIPT_DIR
# Grafana
GRAFANA_CFG='
# Additional Config
[server]
http_port = 3030
[auth.anonymous]
enabled = true
org_role = Admin
[security]
allow_embedding = true
[users]
#home_page = "/d/rYdddlPWk/node-exporter-full"
home_page = "/d/candemo/candemo"
#home_page = "/d/candemodual/candemo_dual"
[panels]
disable_sanitize_html = true
'
if [[ "$(grep 'Additional Config' ./grafana/conf/defaults.ini)" == "" ]]; then
    echo "$GRAFANA_CFG" >> ./grafana/conf/defaults.ini
fi
GRAFANA_DATASOURCE_CFG='
# Additional Config
# # config file version
apiVersion: 1
datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    uid: prometheus
    url: http://localhost:9090
    isDefault: true
    version: 1
    editable: false
'
echo "$GRAFANA_DATASOURCE_CFG" > ./grafana/conf/provisioning/datasources/sample.yaml
GRAFANA_DASHBOARD_CFG="
# Additional Config
apiVersion: 1
providers:
  - name: \"Node exporter Full\"
    orgId: 1
    folder: \"\"
    folderUid: \"\"
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: ${SCRIPT_DIR}/grafana/conf/provisioning/dashboards/node-exporter-full.json
      foldersFromFilesStructure: false
  - name: \"CAN Demo\"
    orgId: 1
    folder: \"\"
    folderUid: \"\"
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: ${SCRIPT_DIR}/grafana/conf/provisioning/dashboards/can_demo_dashboard_single.json
      foldersFromFilesStructure: false
  - name: \"CAN Demo Dual\"
    orgId: 1
    folder: \"\"
    folderUid: \"\"
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: ${SCRIPT_DIR}/grafana/conf/provisioning/dashboards/can_demo_dashboard_dual.json
      foldersFromFilesStructure: false
"
echo "$GRAFANA_DASHBOARD_CFG" > ./grafana/conf/provisioning/dashboards/sample.yaml

# Prometheus
PROMETHEUS_CFG='
# Additional Config
  - job_name: "localhost-node"
    scrape_interval: 1s
    static_configs:
    - targets: ["localhost:9100"]
'
if [[ "$(grep 'Additional Config' ./prometheus/prometheus.yml)" == "" ]]; then
    echo "$PROMETHEUS_CFG" >> ./prometheus/prometheus.yml
fi

