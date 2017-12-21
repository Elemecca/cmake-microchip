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
include(MicrochipBin2Hex)
include(MicrochipIPE)
include(MicrochipPathSearch)

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
    set(MICROCHIP_MCU_FAMILY "${CMAKE_MATCH_1}${CMAKE_MATCH_2}" CACHE STRING "Familia de chip")
    set(MICROCHIP_MCU_MODEL  "${CMAKE_MATCH_2}${CMAKE_MATCH_3}" CACHE STRING "Modelo de chip")

    if(MICROCHIP_MCU_FAMILY IN_LIST MICROCHIP_FAMILIES_8)
        set(CMAKE_SYSTEM_PROCESSOR "PIC_8")
        add_definitions(-D__${MICROCHIP_MCU_FAMILY}__ -D__${MICROCHIP_MCU_MODEL}__)
    elseif(MICROCHIP_MCU_FAMILY IN_LIST MICROCHIP_FAMILIES_16)
        set(CMAKE_SYSTEM_PROCESSOR "PIC_16")
        add_definitions(-D__${MICROCHIP_MCU_FAMILY}__ -D__${MICROCHIP_MCU_MODEL}__)
    elseif(MICROCHIP_MCU_FAMILY IN_LIST MICROCHIP_FAMILIES_32)
        set(CMAKE_SYSTEM_PROCESSOR "PIC_32")
        add_definitions(-D__${MICROCHIP_MCU_FAMILY}__ -D__${MICROCHIP_MCU_MODEL}__)
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

#En caso de estar ya configurado el compilador, restauro los flags
message(STATUS "microchip toolchain")
if(MICROCHIP_XC32_PATH)
    set(link_flags "")
    set(compile_flags "")
    
    if(MICROCHIP_MCU_FAMILY STREQUAL "PIC32MX")
        set(lib_directory pic32mx)
    else()
        set(lib_directory pic32-libs)
    endif()
    
    include_directories(SYSTEM ${MICROCHIP_XC32_PATH}/${lib_directory}/include)

    list(APPEND compile_flags
            "-mprocessor=${MICROCHIP_MCU_MODEL}"
    )
    string(APPEND link_flags
            " -mprocessor=${MICROCHIP_MCU_MODEL}"
    )
    if(MICROCHIP_LINK_SCRIPT OR MICROCHIP_MIN_HEAP_SIZE)
            string(APPEND link_flags
                    " -Wl"
            )
            if(MICROCHIP_LINK_SCRIPT)
                    string(APPEND link_flags
                            ",--script=\"${MICROCHIP_LINK_SCRIPT}\""
                    )
            endif()
            if(MICROCHIP_MIN_HEAP_SIZE)
                    string(APPEND link_flags
                            ",--defsym=_min_heap_size=${MICROCHIP_MIN_HEAP_SIZE}"
                    )
            endif()
            if(MICROCHIP_MAP_FILE)
                    string(APPEND link_flags
                            ",-Map=\"${MICROCHIP_MAP_FILE}\""
                    )
                    set_property(DIRECTORY APPEND
                            PROPERTY ADDITIONAL_MAKE_CLEAN_FILES
                            "${MICROCHIP_MAP_FILE}"
                    )
            endif()
    endif()
    string(APPEND CMAKE_C_LINK_FLAGS
        ${link_flags}
    )
    add_compile_options(
        ${compile_flags}
    )
    add_compile_options(
        "$<$<CONFIG:RELASE>:-DNDEBUG>"
        "$<$<CONFIG:DEBUG>:-g>"
    )
endif()
