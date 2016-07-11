#=============================================================================
# Copyright 2016 Sam Hanes
#
# Distributed under the OSI-approved BSD License (the "License");
# see accompanying file COPYING.txt for details.
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the License for more information.
#=============================================================================
# (To distribute this file outside of CMake-Microchip,
#  substitute the full License text for the above reference.)

# `CMAKE_TOOLCHAIN_FILE` should be set to the path to this file in
# CMakeLists.txt before the `project` command, for example:
#   set(CMAKE_TOOLCHAIN_FILE external/cmake-microchip/toolchain.cmake)
#
# doing so will trigger CMake's cross-compiling support
# this module will be loaded during the system detection process
# to provide information about the target platform


# CMP0057 (IN_LIST operator) since 3.3
cmake_minimum_required(VERSION 3.3)


# record the directory containing this script
# it will be used as the base for finding our other files
set(MICROCHIP_ROOT ${CMAKE_CURRENT_LIST_DIR})

# add our modules to the search path
list(APPEND CMAKE_MODULE_PATH "${MICROCHIP_ROOT}/Modules")


# set the target platform
# this is what causes CMake to call our modules during setup
set(CMAKE_SYSTEM_NAME "MicrochipMCU")

# set the default MCU model
# handling the default this way produces this priority order:
#
#   1. the value already set in the cache, if one exists
#      e.g. from "-DMICROCHIP_MCU=..." on the command line
#
#   2. a non-cache value already set
#      e.g. with "set(MICROCHIP_MCU ...)" in CMakeLists.txt
#
#   3. the default value
#
# that makes it possible to set a per-project default model in
# CMakeLists.txt that can still be overridden on the command line
if(NOT MICROCHIP_MCU)
    set(MICROCHIP_MCU "generic16")
endif()
set(MICROCHIP_MCU "${MICROCHIP_MCU}"
    CACHE STRING "full model number of the target Microchip MCU"
)


# known 8-bit MCU families
list(APPEND MICROCHIP_FAMILIES_8
    PIC12F
    PIC16F
    PIC18F
)

# known 16-bit MCU families
list(APPEND MICROCHIP_FAMILIES_16
    dsPIC30F
    dsPIC33E
    dsPIC33F
    PIC24E
    PIC24F
    PIC24H
)

# known 32-bit MCU families
list(APPEND MICROCHIP_FAMILIES_32
    PIC32MX
    PIC32MZ
)


# parse the MCU model
if(MICROCHIP_MCU STREQUAL "generic8")
    set(MICROCHIP_MCU_FAMILY   "generic")
    set(MICROCHIP_MCU_MODEL    "generic")
    set(CMAKE_SYSTEM_PROCESSOR "PIC_8")

elseif(MICROCHIP_MCU STREQUAL "generic16")
    set(MICROCHIP_MCU_FAMILY   "generic")
    set(MICROCHIP_MCU_MODEL    "p30sim")
    set(CMAKE_SYSTEM_PROCESSOR "PIC_16")

elseif(MICROCHIP_MCU STREQUAL "generic32")
    set(MICROCHIP_MCU_FAMILY   "generic")
    set(MICROCHIP_MCU_MODEL    "generic")
    set(CMAKE_SYSTEM_PROCESSOR "PIC_32")

elseif(MICROCHIP_MCU MATCHES "^(dsPIC|PIC)(32M[XZ]|[0-9]+[A-Z])([A-Z0-9]+)$")
    set(MICROCHIP_MCU_FAMILY "${CMAKE_MATCH_1}${CMAKE_MATCH_2}")
    set(MICROCHIP_MCU_MODEL  "${CMAKE_MATCH_2}${CMAKE_MATCH_3}")

    if(MICROCHIP_MCU_FAMILY IN_LIST MICROCHIP_FAMILIES_8)
        set(CMAKE_SYSTEM_PROCESSOR "PIC_8")
    elseif(MICROCHIP_MCU_FAMILY IN_LIST MICROCHIP_FAMILIES_16)
        set(CMAKE_SYSTEM_PROCESSOR "PIC_16")
    elseif(MICROCHIP_MCU_FAMILY IN_LIST MICROCHIP_FAMILIES_32)
        set(CMAKE_SYSTEM_PROCESSOR "PIC_32")
    else()
        message(FATAL_ERROR
            "Unsupported MCU family '${MICROCHIP_MCU_FAMILY}'."
        )
    endif()

else()
    message(FATAL_ERROR
        "Invalid MICROCHIP_MCU value '${MICROCHIP_MCU}'."
    )
endif()
