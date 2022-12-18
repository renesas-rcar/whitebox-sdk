FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append = " \
    file://aos_vis.cfg \
    file://aos-vis.service \
"

AOS_VIS_PLUGINS = " \
    plugins/vinadapter \
    plugins/boardmodeladapter \
    plugins/subjectsadapter \
"

python __anonymous() {
    if d.getVar('VIS_DATA_PROVIDER'):
        d.appendVar('AOS_VIS_PLUGINS', 'plugins/${VIS_DATA_PROVIDER}')
}

VIS_CERTS_PATH = "${base_prefix}/usr/share/aos/vis/certs"

inherit systemd

SYSTEMD_SERVICE_${PN} = "aos-vis.service"

FILES_${PN} += " \
    ${sysconfdir} \
    ${systemd_system_unitdir} \
    ${VIS_CERTS_PATH} \
    ${localstatedir} \
"

RDEPENDS_${PN} += "\
    aos-rootca \
    ${@bb.utils.contains('AOS_VIS_PLUGINS', 'plugins/telemetryemulatoradapter', 'telemetry-emulator', '', d)} \
"

python do_configure_adapters() {
    import json

    file_name = oe.path.join(d.getVar("D"), d.getVar("sysconfdir"), "aos", "aos_vis.cfg")

    with open(file_name) as f:
        data = json.load(f)

    adapter_list = [os.path.basename(adapter) for adapter in d.getVar("AOS_VIS_PLUGINS").split()]
    data["Adapters"] = [adapter for adapter in data["Adapters"] if adapter["Plugin"] in adapter_list]

    with open(file_name, "w") as f:
        json.dump(data, f, indent=4)
}

do_install_append() {
    install -d ${D}${sysconfdir}/aos
    install -m 0644 ${WORKDIR}/aos_vis.cfg ${D}${sysconfdir}/aos

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/aos-vis.service ${D}${systemd_system_unitdir}/aos-vis.service

    if "${@bb.utils.contains('AOS_VIS_PLUGINS', 'plugins/telemetryemulatoradapter', 'true', 'false', d)}"; then
        sed -i -e 's/network-online.target/network-online.target telemetry-emulator.service/g' ${D}${systemd_system_unitdir}/aos-vis.service
        sed -i -e '/ExecStart/i ExecStartPre=/bin/sleep 1' ${D}${systemd_system_unitdir}/aos-vis.service
    fi

    install -d ${D}${VIS_CERTS_PATH}
    install -m 0644 ${S}/src/${GO_IMPORT}/data/*.pem ${D}${VIS_CERTS_PATH}
}

pkg_postinst_${PN}() {
    # Add wwwivi to /etc/hosts
    if ! grep -q 'wwwivi' $D${sysconfdir}/hosts ; then
        echo '127.0.0.1	wwwivi' >> $D${sysconfdir}/hosts
    fi
}

addtask configure_adapters after do_install before do_package
