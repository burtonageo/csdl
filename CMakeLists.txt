cmake_minimum_required(VERSION 2.8)

project(csdl)

set (CSDL_SOURCE_DIR  "${CMAKE_CURRENT_SOURCE_DIR}/src")
set (CSDL_INCLUDE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/include")

if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
  set (SOURCES "${CSDL_SOURCE_DIR}/csdl_appkit.m")

  #find_library(COREFOUNDATION_FRAMEWORK CoreFoundation)
  find_library (COCOA_FRAMEWORK Cocoa)

  find_path (COCOA_INCLUDE_DIR Cocoa/Cocoa.h)
  message("${COCOA_INCLUDE_DIR}")
  include_directories ("${COCOA_INCLUDE_DIR}/Headers")
endif()

if (${CMAKE_SYSTEM_NAME} MATCHES "Linux")
  set (SOURCES "${CSDL_SOURCE_DIR}/csdl_gtk3.c")
endif()

if (${CMAKE_SYSTEM_NAME} MATCHES "Windows")
  set (SOURCES "${CSDL_SOURCE_DIR}/csdl_win.c")
endif()

include_directories (${CSDL_INCLUDE_DIR})
add_library (${PROJECT_NAME} ${SOURCES})
target_link_libraries (${PROJECT_NAME} ${COCOA_FRAMEWORK})