FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

RENESASOTA_IMPORT = "github.com/aoscloud/aos-core-rcar-gen4"

SRC_URI_append = " \
    git://git@${RENESASOTA_IMPORT}.git;branch=main;protocol=ssh;name=renesasota;destsuffix=${S}/src/${GO_IMPORT}/vendor/${RENESASOTA_IMPORT} \
"

SRCREV_FORMAT = "renesasota"
SRCREV_renesasota = "0b701b26bc5f7b663e331a9d6ec426f28b7a01a7"

SRC_URI_append = "\
    file://aos_updatemanager.cfg \
    file://aos-updatemanager.service \
    file://aos-reboot.service \
"

AOS_UM_UPDATE_MODULES ?= "\
    updatemodules/overlayxenstore \
    updatemodules/ubootdualpart \
"

inherit systemd

SYSTEMD_SERVICE_${PN} = "aos-updatemanager.service"

MIGRATION_SCRIPTS_PATH = "${base_prefix}/usr/share/aos/um/migration"

FILES_${PN} += " \
    ${bindir} \
    ${sysconfdir} \
    ${systemd_system_unitdir} \
    ${MIGRATION_SCRIPTS_PATH} \
"

RDEPENDS_${PN} = " \
    aos-rootca \
"

python do_update_componet_ids() {
    import json

    file_name = oe.path.join(d.getVar("D"), d.getVar("sysconfdir"), "aos", "aos_updatemanager.cfg")

    with open(file_name) as f:
        data = json.load(f)

    for update_module in data["UpdateModules"]:
        update_module["ID"] = d.getVar("BOARD_MODEL")+"-"+d.getVar("BOARD_VERSION")+"-"+update_module["ID"]

    with open(file_name, 'w') as f:
        json.dump(data, f, indent=4)
}

do_prepare_modules_append() {
    file="${S}/src/${GO_IMPORT}/updatemodules/modules.go"

    echo 'import _ "${RENESASOTA_IMPORT}/updatemodules/renesasota"' >> ${file}
}

do_compile() {
    VENDOR_PACKAGES=" \
        github.com/syucream/posix_mq \
        github.com/aoscloud/aos_common/aostypes \
    "

    for package in $VENDOR_PACKAGES; do
        install -d $(dirname ${S}/src/${GO_IMPORT}/vendor/${package})
        ln -sfr ${S}/src/${GO_IMPORT}/vendor/${RENESASOTA_IMPORT}/vendor/${package} ${S}/src/${GO_IMPORT}/vendor/${package}
    done 

    cd ${S}/src/${GO_IMPORT}
    GO111MODULE=on ${GO} build -o ${B}/bin/aos_updatemanager -ldflags "-X main.GitSummary=`git --git-dir=.git describe --tags --always`"
}

do_install_append() {
    install -d ${D}${bindir}
    install -m 0755 ${B}/bin/aos_updatemanager ${D}${bindir}

    install -d ${D}${sysconfdir}/aos
    install -m 0644 ${WORKDIR}/aos_updatemanager.cfg ${D}${sysconfdir}/aos

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/aos-updatemanager.service ${D}${systemd_system_unitdir}/aos-updatemanager.service
    install -m 0644 ${WORKDIR}/aos-reboot.service ${D}${systemd_system_unitdir}/aos-reboot.service

    install -d ${D}${MIGRATION_SCRIPTS_PATH}
    source_migration_path="src/${GO_IMPORT}/database/migration"
    if [ -d ${S}/${source_migration_path} ]; then
        install -m 0644 ${S}/${source_migration_path}/* ${D}${MIGRATION_SCRIPTS_PATH}
    fi
}

addtask update_componet_ids after do_install before do_package
