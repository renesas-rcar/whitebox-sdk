FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append = " \
    file://weston.service.new \
"

do_install_append () {
    # Remove conflict file
    rm -f ${D}/${sysconfdir}/default/weston

    # Add process to create directory on $XDG_RUNTIME_DIR
    echo 'mkdir -p $XDG_RUNTIME_DIR' >> ${D}/${sysconfdir}/profile.d/weston.sh

    # Replace sevice filr
    cp -f ${WORKDIR}/weston.service.new ${D}/${systemd_system_unitdir}/weston@.service

    # Fix service file
    # sed -e "/^After=/s/$/ dbus.service multi-user.target/" \
    #     -e "s/\$OPTARGS/--idle-time=0 \$OPTARGS/" \
    #     -i ${D}/${systemd_system_unitdir}/weston@.service
    # echo 'Restart=on-failure' >> ${D}/${systemd_system_unitdir}/weston@.service
    # echo 'RestartSec=5s' >> ${D}/${systemd_system_unitdir}/weston@.service
    # sed -i 's/-start -v -e -- $OPTARGS/ --tty 1/' ${D}/${systemd_system_unitdir}/weston@.service

    #echo '[Install]'  >> ${D}/${systemd_system_unitdir}/weston@.service
    #echo 'WantedBy=graphical.target'  >> ${D}/${systemd_system_unitdir}/weston@.service

    # Add config for autostart weston
    #echo '[core]'
    #require-input = false
}

