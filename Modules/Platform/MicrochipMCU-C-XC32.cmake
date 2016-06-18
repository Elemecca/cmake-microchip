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

# this module is called by `Platform/MicrochipMCU-C`
# to provide information specific to the XC32 compiler

include(MicrochipPathSearch)
MICROCHIP_PATH_SEARCH(MICROCHIP_XC32_PATH xc32
    CACHE "the path to a Microchip XC32 installation"
    STORE_VERSION MICROCHIP_C_COMPILER_VERSION
)

if(NOT MICROCHIP_XC32_PATH)
    message(FATAL_ERROR
        "No Microchip XC32 compiler was found. Please provide the path"
        " to an XC32 installation on the command line, for example:\n"
        "cmake -DMICROCHIP_XC32_PATH=/opt/microchip/xc32/v1.42 ."
    )
endif()

set(CMAKE_FIND_ROOT_PATH ${MICROCHIP_XC32_PATH})

set(CMAKE_C_COMPILER xc32-gcc)
set(MICROCHIP_C_COMPILER_ID XC32)

add_compile_options(
    "-mprocessor=${MICROCHIP_MCU_MODEL}"
)
string(APPEND CMAKE_C_LINK_FLAGS
    " -mprocessor=${MICROCHIP_MCU_MODEL}"
)
