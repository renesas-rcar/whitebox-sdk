
BRANCH = "main"
SRC_URI = "git://github.com/yhamamachi/automotive-viss2-client.git;branch=${BRANCH};protocol=https"
# Support changin theme while ALC is receiving
#SRCREV = "51f0b47b793927117cb5ec034da9ae9ddd306db0"
# Not Support changing theme while ALC is receiving
SRCREV = "bf1980acbcef1ee8911d4e1236e0b272e8c68efc"

BG_COLOR="11, 66, 121"
BASE_COLOR1="179,214,255"
BASE_COLOR2="153,204,255"
BASE_COLOR3="0,102,255"


do_configure_append () {
#    TARGET_FILES=(./src/components/CircleMeter.js ./src/components/SideBar.js ./src/components/GaugeV2.js)

    cd ${B}/cluster-app
    git reset --hard

    if [ "${BG_COLOR_AFTER}" != "" ]; then
        sed -i "s/${BG_COLOR}/${BG_COLOR_AFTER}/" ./src/ClusterApp.css
    fi

#    for fname in ${TARGET_FILES[@]}; do
    for fname in ./src/components/CircleMeter.js ./src/components/SideBar.js ./src/components/GaugeV2.js; do
        if [ "${BASE_COLOR_AFTER}" != "" ]; then
            sed -i "s/${BASE_COLOR1}/${BASE_COLOR_AFTER}/" $fname
            sed -i "s/${BASE_COLOR2}/${BASE_COLOR_AFTER}/" $fname
        fi

        if [ "${ANIME_COLOR_AFTER}" != "" ]; then
            sed -i "s/${BASE_COLOR3}/${ANIME_COLOR_AFTER}/" $fname
        fi
    done
}

