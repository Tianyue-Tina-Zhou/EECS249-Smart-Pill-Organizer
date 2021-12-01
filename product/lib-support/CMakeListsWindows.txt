cmake_minimum_required(VERSION 3.12)
set(ENV{PICO_SDK_PATH} "../../../../../pico-sdk")
set(PICO_PLATFORM rp2040)
include(../../../../../pico-sdk/external/pico_sdk_import.cmake)

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

add_subdirectory(waveshare/Config/)
add_subdirectory(waveshare/Infrared/)
add_subdirectory(waveshare/LCD/)
add_subdirectory(waveshare/Fonts/)
add_subdirectory(waveshare/GUI/)
add_subdirectory(waveshare/ColorSensor/)

include_directories(./waveshare/Config)
include_directories(./waveshare/GUI)
include_directories(./waveshare/LCD)
include_directories(./waveshare/Infrared)
include_directories(./waveshare/ColorSensor)

include_directories(${CoreLib})
include_directories(${CoreLib}/platform)
include_directories(${CoreLib}/federated)

pico_sdk_init()

add_executable(SPO Main.c core/platform/lf_pico_support.c ctarget.c)

pico_add_extra_outputs(SPO)

# enable usb output, disable uart output
pico_enable_stdio_usb(SPO 1)
pico_enable_stdio_uart(SPO 0)

target_link_libraries(SPO LCD Infrared GUI Fonts ColorSensor Config pico_stdlib hardware_spi hardware_i2c)
