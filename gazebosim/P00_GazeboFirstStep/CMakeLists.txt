cmake_minimum_required(VERSION 3.10.2 FATAL_ERROR)

project(avoid_wall)

find_package(gz-transport13 REQUIRED)
find_package(gz-msgs10 REQUIRED)

add_executable(lidar_node lidar_node.cc)

target_link_libraries(lidar_node 
  gz-transport13::core
  gz-msgs10::core
)
