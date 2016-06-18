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
# to set up information specific to Microchip GNU C compilers

# for XC16, inject properties that may have been missed
# see `Platform/MicrochipMCU-C-XC16` for explanation
if(MICROCHIP_C_COMPILER_ID STREQUAL "XC16")
    if(NOT CMAKE_C_COMPILE_FEATURES)
        set(CMAKE_C_COMPILE_FEATURES "c_function_prototypes;c_restrict;c_variadic_macros")
        set(CMAKE_C90_COMPILE_FEATURES "c_function_prototypes")
        set(CMAKE_C99_COMPILE_FEATURES "c_restrict;c_variadic_macros")
        set(CMAKE_C11_COMPILE_FEATURES "")
    endif()

    if(NOT CMAKE_C_SIZEOF_DATA_PTR)
        set(CMAKE_C_SIZEOF_DATA_PTR 2)
    endif()

    if(NOT CMAKE_C_COMPILER_ABI)
        set(CMAKE_C_COMPILER_ABI ELF)
    endif()
endif()
