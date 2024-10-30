# To limit the build target for reducing memory usage on building
EXTRA_OECMAKE:append = " ${LIBS_BUILD} "

LIBS_BUILD = "\
-DBUILD_ONLY='\
iot;\
iotfleetwise;\
'"

