IMAGE_INSTALL_append = " \
    iccom \
"

python () {
    if d.getVar("BUILD_SDK", True) == "1":
        # def addtask(task, before, after, d):
        bb.build.addtask('populate_sdk', 'do_build', "do_image_complete", d)
}

