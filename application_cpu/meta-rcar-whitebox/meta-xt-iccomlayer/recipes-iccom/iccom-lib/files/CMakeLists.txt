set(lib_name    "iccom")
set(lib_version "1.0.0")

cmake_minimum_required(VERSION 3.10.2)
project(${lib_name})

set(RCAR_SOC S4)

set(source
	iccom.c
)

set(header
	iccom.h
	iccom_commands.h
	util.h
	iccom_ioctl.h
)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DDEBUG_PRINT_ENABLED -DUSE_IOCTL")

add_library(${lib_name})
target_sources(${lib_name} PRIVATE ${source})

#install(TARGETS ${lib_name} DESTINATION bin)
