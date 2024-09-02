
do_install_append() {
    if [ "${@d.getVar('USE_UFS')}" -eq "1" ]; then
        sed -i 's/mmcblk0p/sda/g' \
            ${D}${sysconfdir}/aos/aos_updatemanager.cfg
    fi
}

GO_IMPORT = "github.com/aosedge/aos_updatemanager"

do_prepare_modules() {
   file="${S}/src/${GO_IMPORT}/updatemodules/modules.go"

   echo 'package updatemodules' > ${file}
   echo 'import (' >> ${file}
   for module in ${AOS_UM_UPDATE_MODULES}; do
       echo "\t_ \"github.com/aoscloud/aos_updatemanager/${module}\"" >> ${file}
   done
   echo ')' >> ${file}
}

