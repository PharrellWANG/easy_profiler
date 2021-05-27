# ﻿cmake_minimum_required(VERSION 3.4.1)

#set (CMAKE_SYSTEM_NAME Darwin)
set (UNIX 1)
set (APPLE 1)
set (OSX 1)

if((NOT DEFINED VE_COMPILE_ARM) OR (VE_COMPILE_ARM STREQUAL "")
    OR (${VE_COMPILE_ARM} MATCHES "(FALSE|false|0|OFF)"))
  message(STATUS "option VE_COMPILE_ARM set OFF")
  option(VE_COMPILE_ARM "" OFF)
elseif(${VE_COMPILE_ARM} MATCHES "(TRUE|true|1|null|ON)")
  message(STATUS "option VE_COMPILE_ARM set ON")
  option(VE_COMPILE_ARM "" ON)
else()
  message(FATAL_ERROR "INVALID FLAG VE_COMPILE_ARM=" ${VE_COMPILE_ARM})
endif()

# Get the Xcode version being used.
execute_process(COMMAND xcodebuild -version
  OUTPUT_VARIABLE XCODE_VERSION
  ERROR_QUIET
  OUTPUT_STRIP_TRAILING_WHITESPACE)
string(REGEX MATCH "Xcode [0-9\\.]+" XCODE_VERSION "${XCODE_VERSION}")
string(REGEX REPLACE "Xcode ([0-9\\.]+)" "\\1" XCODE_VERSION "${XCODE_VERSION}")
string (REGEX REPLACE "^([0-9]+)\\.([0-9]+).*$" "\\1" XCODE_MAJOR_VERSION "${XCODE_VERSION}")
string (REGEX REPLACE "^([0-9]+)\\.([0-9]+).*$" "\\2" XCODE_MINOR_VERSION "${XCODE_VERSION}")
message(STATUS "Building with Xcode version: ${XCODE_VERSION}")

if (VE_COMPILE_ARM AND (${XCODE_MAJOR_VERSION} GREATER 12 OR ((${XCODE_MAJOR_VERSION} EQUAL 12) AND (${XCODE_MINOR_VERSION} GREATER_EQUAL 2))))
  set(OSX_ARCH x86_64 arm64 CACHE STRING "")
else()
  set(OSX_ARCH x86_64 CACHE STRING "")
endif()
message(STATUS "OSX_ARCH: ${OSX_ARCH}")

set(CMAKE_XCODE_ATTRIBUTE_CMAKE_OSX_DEPLOYMENT_TARGET "10.11" CACHE STRING "Deployment target for osx" FORCE)
set(CMAKE_OSX_DEPLOYMENT_TARGET "10.11" CACHE STRING "Deployment target for osx" FORCE)
set(CMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LIBRARY "libc++")
# apple use 'c++0x' instead of 'c++11'
set(CMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LANGUAGE_STANDARD "c++0x")
set(CMAKE_OSX_ARCHITECTURES ${OSX_ARCH} CACHE STRING "Build architecture for osx")
set(CMAKE_XCODE_ARCHS ${OSX_ARCH} CACHE STRING "Build architecture for osx")

macro (find_osx_framework VAR fwname)
    find_library(FRAMEWORK_${fwname}
                 NAMES ${fwname}
                 PATHS ${CMAKE_OSX_SYSROOT}/System/Library
                 PATH_SUFFIXES Frameworks
                 NO_DEFAULT_PATH)

    if(${FRAMEWORK_${fwname}} STREQUAL FRAMEWORK_${fwname}-NOTFOUND)
        message(ERROR "Framework ${fwname} not found")
    else()
        message(STATUS "Framwork ${fwname} found at ${FRAMEWORK_${fwname}}")
        set(${VAR} ${FRAMEWORK_${fwname}})
    endif()
endmacro(find_osx_framework)

macro (set_xcode_attr_property TARGET XCODE_PROPERTY XCODE_VALUE)
    set_property (TARGET ${TARGET} PROPERTY XCODE_ATTRIBUTE_${XCODE_PROPERTY} ${XCODE_VALUE})
endmacro (set_xcode_attr_property)

macro (set_xcode_property TARGET XCODE_PROPERTY XCODE_VALUE)
    set_property (TARGET ${TARGET} PROPERTY ${XCODE_PROPERTY} ${XCODE_VALUE})
endmacro (set_xcode_property)

macro (remove_file_from_list unqualified_list list_to_be_processed)
    foreach(EXCLUDE_SRC ${unqualified_list})
        foreach (TMP_PATH ${list_to_be_processed})
            string (FIND ${TMP_PATH} ${EXCLUDE_SRC} EXCLUDE_FILE_FOUND)
            if (NOT ${EXCLUDE_FILE_FOUND} EQUAL -1)
                list (REMOVE_ITEM list_to_be_processed ${TMP_PATH})
            endif ()
        endforeach(TMP_PATH)
    endforeach(EXCLUDE_SRC)
endmacro (remove_file_from_list)