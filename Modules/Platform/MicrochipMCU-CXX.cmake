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

# This module is loaded during the search for a CXX compiler
# to provide the information necessary to find one.

if(CMAKE_SYSTEM_PROCESSOR STREQUAL "PIC_32")
    include(Platform/MicrochipMCU-CXX-XC32)
else()
    message(FATAL_ERROR
        "No CXX compiler for '${CMAKE_SYSTEM_PROCESSOR}'"
        " is supported yet."
    )
endif()

if(MICROCHIP_CXX_COMPILER_ID)
    message(STATUS
        "Using Microchip CXX compiler ${MICROCHIP_CXX_COMPILER_ID}"
        " ${MICROCHIP_CXX_COMPILER_VERSION}"
    )
endif()
