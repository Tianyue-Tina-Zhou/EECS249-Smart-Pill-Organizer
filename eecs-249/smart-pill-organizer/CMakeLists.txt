cmake_minimum_required(VERSION 3.12)
set(ENV{PICO_SDK_PATH} "../../../pico-sdk")

include(pico_sdk_import.cmake)

project(SPO)

pico_sdk_init()

add_executable(SPO
    main.c
)

pico_add_extra_outputs(SPO)

target_link_libraries(SPO pico_stdlib)