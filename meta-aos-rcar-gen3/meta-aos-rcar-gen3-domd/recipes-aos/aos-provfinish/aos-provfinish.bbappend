do_install_append() {
    sed -i "s:/var/aos:/var:g" ${D}${aos_opt_dir}/provfinish.sh
}

