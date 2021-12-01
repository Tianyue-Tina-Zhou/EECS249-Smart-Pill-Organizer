aux_source_directory(. DIR_ColorSensor_SRCS)

include_directories(../Config)

add_library(ColorSensor ${DIR_ColorSensor_SRCS})
target_link_libraries(ColorSensor PUBLIC Config)