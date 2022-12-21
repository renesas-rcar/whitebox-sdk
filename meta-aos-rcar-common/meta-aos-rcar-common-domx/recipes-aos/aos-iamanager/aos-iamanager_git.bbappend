FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

AOS_IAM_CERT_MODULES = " \
    certhandler/modules/pkcs11module \
"

RDEPENDS_${PN} += " \
    optee-pkcs11-ta \
    optee-client \
"

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
