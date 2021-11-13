cmake_minimum_required(VERSION 3.12)
set(ENV{PICO_SDK_PATH} "../../../../../pico-sdk")

include(../../pico_sdk_import.cmake)

project(SPO)

# Require C11
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Require C++17
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# set(DEFAULT_BUILD_TYPE Release)
# if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
#     set(CMAKE_BUILD_TYPE ${DEFAULT_BUILD_TYPE} CACHE STRING "Choose the type of build." FORCE)
# endif()
set(CoreLib core)

include_directories(${CoreLib})
include_directories(${CoreLib}/platform)
include_directories(${CoreLib}/federated)

pico_sdk_init()

add_executable(SPO Main.c core/platform/lf_pico_support.c ctarget.c)

pico_add_extra_outputs(SPO)

target_link_libraries(SPO pico_stdlib)