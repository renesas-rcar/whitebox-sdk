FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += " \
    file://aos-dirs-service.conf \
"

FILES_${PN} += " \
    ${sysconfdir} \
"

python __anonymous() {
    if len(d.getVar("NODE_LIST").split()) > 1:
        d.appendVar("RDEPENDS_"+d.getVar('PN'), "nfs-exports")
}

do_install_append() {
    install -d ${D}${sysconfdir}/systemd/system/${PN}.service.d
    install -m 0644 ${WORKDIR}/aos-dirs-service.conf ${D}${sysconfdir}/systemd/system/${PN}.service.d/10-aos-dirs-service.conf
}

python do_update_config() {
    import json

    file_name = oe.path.join(d.getVar("D"), d.getVar("sysconfdir"), "aos", "aos_communicationmanager.cfg")

    with open(file_name) as f:
        data = json.load(f)

    nodes = d.getVar("NODE_LIST").split()
    ums = d.getVar("UM_LIST").split()
    node_id = d.getVar("NODE_ID")
 
    # Update IAM servers
    
    data["IAMProtectedServerURL"]= node_id+":8089"
    data["IAMPublicServerURL"] = node_id+":8090"

    # Update SM controller

    sm_controller = data["SMController"]

    if len(nodes) > 1:
        sm_controller["FileServerURL"] = node_id+":8094" 
 
    sm_controller["NodeIDs"] = []

    for node in nodes:
        sm_controller["NodeIDs"].append(node)

    # Update CM controller

    um_controller = data["UMController"]

    if len(ums) > 1:
        um_controller["FileServerURL"] = node_id+":8092" 
 
    um_controller["UMClients"] = []

    for um in ums:
        um_client = {"UMID": um}

        if um == node_id:
            um_client["IsLocal"] = True
            um_client["Priority"] = 1

        um_controller["UMClients"].append(um_client)

    with open(file_name, "w") as f:
        json.dump(data, f, indent=4)
}

addtask update_config after do_install before do_package
