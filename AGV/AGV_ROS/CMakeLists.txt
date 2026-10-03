cmake_minimum_required(VERSION 3.0.2)
project(aviation_warehouse)

find_package(catkin REQUIRED)

catkin_package()

install(DIRECTORY worlds launch
  DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION}
)
