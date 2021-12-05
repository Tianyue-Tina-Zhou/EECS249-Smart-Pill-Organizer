aux_source_directory(. DIR_IMU_SRCS)

include_directories(../Config)

add_library(IMU ${DIR_IMU_SRCS})
target_link_libraries(IMU PUBLIC Config)
