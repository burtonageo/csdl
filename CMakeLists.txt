cmake_minimum_required(VERSION 2.8)

project(csdl)

set (SRC_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src")

if (${CMAKE_SYSTEM_NAME} matches "Darwin")
  set (SOURCES "${SRC_DIR}/csdl_appkit.m")
endif()

if (${CMAKE_SYSTEM_NAME} matches "Linux")
  set (SOURCES "${SRC_DIR}/csdl_gtk3.c")
endif()

if (${CMAKE_SYSTEM_NAME} matches "Windows")
  set (SOURCES "${SRC_DIR}/csdl_win.c")
endif()
