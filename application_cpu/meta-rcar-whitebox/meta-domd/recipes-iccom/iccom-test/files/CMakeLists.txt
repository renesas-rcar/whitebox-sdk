set(app_name    "iccom-test")
set(app_version "2.0.0")

cmake_minimum_required(VERSION 3.10.2)
project(${app_name})

set(RCAR_SOC S4)

set(source
	main.c
)

set(header
	iccom_commands.h
	util.h
)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DDEBUG_PRINT_ENABLED -DLINUX_TEST_APP")

add_executable(${app_name})
target_sources(${app_name} PRIVATE ${source})
target_link_libraries(${app_name} PRIVATE iccom)

install(TARGETS ${app_name} DESTINATION bin)
