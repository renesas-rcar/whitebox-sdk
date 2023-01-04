FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += " \
    file://optee-identity.conf \
"

AOS_IAM_CERT_MODULES = " \
    certhandler/modules/pkcs11module \
"

FILES_${PN} += " \
    ${sysconfdir} \
"

RDEPENDS_${PN} += " \
    optee-pkcs11-ta \
    optee-client \
    aos-setupdisk \
"

do_install_append() {
    install -d ${D}${sysconfdir}/systemd/system/${PN}.service.d
    install -d ${D}${sysconfdir}/systemd/system/${PN}-provisioning.service.d
    install -m 0644 ${WORKDIR}/optee-identity.conf ${D}${sysconfdir}/systemd/system/${PN}.service.d/20-optee-identity.conf
    install -m 0644 ${WORKDIR}/optee-identity.conf ${D}${sysconfdir}/systemd/system/${PN}-provisioning.service.d/20-optee-identity.conf
}

python do_update_config() {
    import json

    file_name = oe.path.join(d.getVar("D"), d.getVar("sysconfdir"), "aos", "aos_iamanager.cfg")

    with open(file_name) as f:
        data = json.load(f)

    # Set node ID and node type
    
    node_info = {
        "NodeID": d.getVar("NODE_ID"),
        "NodeType" : d.getVar("NODE_TYPE")
    }

    data = {**node_info, **data}

    # Set alternative names for server certificates

    for cert_module in data["CertModules"]:
        if "ExtendedKeyUsage" in cert_module and "serverAuth" in cert_module["ExtendedKeyUsage"]:
            cert_module["AlternativeNames"] = [d.getVar("NODE_ID")]

    with open(file_name, "w") as f:
        json.dump(data, f, indent=4)
}

addtask update_config after do_install before do_package
