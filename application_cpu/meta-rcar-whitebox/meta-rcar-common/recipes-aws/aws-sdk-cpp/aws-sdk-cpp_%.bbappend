# To limit the build target for reducing memory usage on building
EXTRA_OECMAKE:append = " ${LIBS_BUILD} "

# This is used to avoid parallel build
DEPENDS:append = " \
    vsomeip \
    ${@oe.utils.conditional("USE_SYSTEM_MONITOR", "1", "grafana", "", d)} \
"

LIBS_BUILD = "\
-DBUILD_ONLY='\
iot;\
iotfleetwise;\
'"

