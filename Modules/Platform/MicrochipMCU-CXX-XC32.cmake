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

# this module is called by `Platform/MicrochipMCU-CXX`
# to provide information specific to the XC32 compiler

include(MicrochipPathSearch)
if(NOT MICROCHIP_XC32_PATH)
    MICROCHIP_PATH_SEARCH(MICROCHIP_XC32_PATH xc32
        CACHE "the path to a Microchip XC32 installation"
        STORE_VERSION MICROCHIP_CXX_COMPILER_VERSION
    )
endif()

if(NOT MICROCHIP_XC32_PATH)
    message(FATAL_ERROR
        "No Microchip XC32 compiler was found. Please provide the path"
        " to an XC32 installation on the command line, for example:\n"
        "cmake -DMICROCHIP_XC32_PATH=/opt/microchip/xc32/v1.42 ."
    )
endif()

set(CMAKE_FIND_ROOT_PATH ${MICROCHIP_XC32_PATH})

set(OS_SUFFIX "")
if(WIN32)
    string(APPEND OS_SUFFIX ".exe")
endif()

set(CMAKE_CXX_COMPILER ${MICROCHIP_XC32_PATH}/bin/xc32-g++${OS_SUFFIX} CACHE STRING "" FORCE)
set(MICROCHIP_CXX_COMPILER_ID XC32)

set(CMAKE_CXX_FLAGS "-mprocessor=${MICROCHIP_MCU_MODEL}" CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS_RELEASE "-DNDEBUG" CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS_DEBUG "-g" CACHE STRING "" FORCE)
set(CMAKE_EXECUTABLE_SUFFIX_CXX ".elf" CACHE STRING "" FORCE)
