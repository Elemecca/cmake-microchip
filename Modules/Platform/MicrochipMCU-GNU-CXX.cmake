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

# this module is called after the compiler has been determined
# to set up information specific to Microchip GNU CXX compilers

# for XC32, inject properties that may have been missed
# see `Platform/MicrochipMCU-CXX-XC32` for explanation

if(MICROCHIP_CXX_COMPILER_ID STREQUAL "XC32")
    if(NOT CMAKE_CXX_SIZEOF_DATA_PTR)
        set(CMAKE_CXX_SIZEOF_DATA_PTR 4)
    endif()

    if(NOT CMAKE_CXX_COMPILER_ABI)
        set(CMAKE_CXX_COMPILER_ABI ELF)
    endif()
endif()
