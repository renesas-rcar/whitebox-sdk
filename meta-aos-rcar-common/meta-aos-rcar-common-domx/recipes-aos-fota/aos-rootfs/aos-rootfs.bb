SUMMARY = "Recipe to generate AOS rootfs update"
LICENSE = "Apache-2.0"

inherit rootfs-image-generator

do_create_rootfs_image[nostamp] = "1"

addtask create_rootfs_image after do_compile before do_build
