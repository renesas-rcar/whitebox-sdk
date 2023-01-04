FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += " \
    file://optee-identity.conf \
    file://aos-dirs-service.conf \
    file://reboot-on-failure.conf \
    file://aos-reboot.service \
"

AOS_UM_UPDATE_MODULES = " \
    updatemodules/overlayxenstore \
    updatemodules/ubootdualpart \
"

FILES_${PN} += " \
    ${sysconfdir} \
    ${systemd_system_unitdir} \
"

do_install_append() {
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/aos-reboot.service ${D}${systemd_system_unitdir}/aos-reboot.service

    install -d ${D}${sysconfdir}/systemd/system/${PN}.service.d
    install -m 0644 ${WORKDIR}/optee-identity.conf ${D}${sysconfdir}/systemd/system/${PN}.service.d/20-optee-identity.conf
    install -m 0644 ${WORKDIR}/aos-dirs-service.conf ${D}${sysconfdir}/systemd/system/${PN}.service.d/20-aos-dirs-service.conf
    install -m 0644 ${WORKDIR}/reboot-on-failure.conf ${D}${sysconfdir}/systemd/system/${PN}.service.d/20-reboot-on-failure.conf
}

python do_update_config() {
    import json

    file_name = oe.path.join(d.getVar("D"), d.getVar("sysconfdir"), "aos", "aos_updatemanager.cfg")

    with open(file_name) as f:
        data = json.load(f)
 
    # Update IAM servers
    
    data["IAMPublicServerURL"] = d.getVar("HOST_NAME")+"."+d.getVar("DOMAIN_NAME")+":8090"

    # Update CM server

    data["CMServerURL"] = d.getVar("MAIN_NODE_ADDRESS")+":8091"

    # Update component IDs

    for update_module in data["UpdateModules"]:
        update_module["ID"] = d.getVar("UNIT_MODEL")+"-"+d.getVar("UNIT_VERSION")+"-"+d.getVar("DOMAIN_NAME")+"-"+update_module["ID"]

    with open(file_name, "w") as f:
        json.dump(data, f, indent=4)
}

addtask update_config after do_install before do_package
