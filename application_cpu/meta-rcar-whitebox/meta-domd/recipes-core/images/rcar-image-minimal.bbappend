IMAGE_INSTALL_append = " \
    iccom \
"

python () {
    if d.getVar("BUILD_SDK", True) == "1":
        # def addtask(task, before, after, d):
        bb.build.addtask('populate_sdk', 'do_build', "do_image_complete", d)
}

do_deploy_copy_var() {
    install -d ${DEPLOY_DIR_IMAGE}
    cp -rf ${S}/../rootfs/var -t ${DEPLOY_DIR_IMAGE}
}

addtask deploy_copy_var before do_image after do_rootfs

