#!/bin/sh

set -e

dom_id=$(xl domid $1)
xenpath="/local/domain/$dom_id/control/user-reboot"

xenstore-write $xenpath 1
xenstore-chmod $xenpath b$dom_id

xenstore-watch $xenpath | while read event; do
    value="$(xenstore-read $xenpath)"

    [[ $value == 2* ]] && {
        echo "Reboot request from domain: $1"
        reboot
    }
done
