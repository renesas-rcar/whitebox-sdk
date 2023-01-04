FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += " \
    file://aos-vis-service.conf \
"

AOS_IAM_IDENT_MODULES = " \
    identhandler/modules/visidentifier \
"

FILES_${PN} += " \
    ${sysconfdir}/systemd/system/aos-iamanager.service.d/ \
"

RDEPENDS_${PN} += " \
    aos-setupdisk \
"

do_install_append() {
    install -d ${D}${sysconfdir}/systemd/system/aos-iamanager.service.d
    install -m 0644 ${WORKDIR}/aos-vis-service.conf ${D}${sysconfdir}/systemd/system/aos-iamanager.service.d/10-aos-vis-service.conf
}

python do_update_config_append() {
    # Add remote IAM's configuration

    data["RemoteIams"] = []

    node_addresses = d.getVar("NODE_ADDRESSES").split()

    for i, node in enumerate(d.getVar("NODE_LIST").split()):
        if node != d.getVar("NODE_ID"):
            data["RemoteIams"].append({"NodeID": node, "URL": node_addresses[i]+":8089"})

    with open(file_name, "w") as f:
        json.dump(data, f, indent=4)
}
