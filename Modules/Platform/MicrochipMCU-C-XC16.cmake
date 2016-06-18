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
# to provide information specific to the XC16 compiler

include(MicrochipPathSearch)
MICROCHIP_PATH_SEARCH(MICROCHIP_XC16_PATH xc16
    CACHE "the path to a Microchip XC16 installation"
    BAD_VERSIONS 1.26
)

if(NOT MICROCHIP_XC16_PATH)
    message(FATAL_ERROR
        "No Microchip XC16 compiler was found. Please provide the path"
        " to an XC16 installation on the command line, for example:\n"
        "cmake -DMICROCHIP_XC16_PATH=/opt/microchip/xc16/v1.25 ."
    )
endif()

set(CMAKE_FIND_ROOT_PATH ${MICROCHIP_XC16_PATH})



# Unfortunately the normal CMake compiler detection process doesn't work
# with XC16. It functions by compiling a file which uses preprocessor
# conditionals to determine the compiler type and version and puts that
# information in string literals, then running `strings` on the output
# file and parsing out the detected values. That fails for XC16 because
# string literals are not packed contiguously and therefore `strings`
# can't find them.
#
# In intermediate object files, XC16 handles character literals as
# 16-bit integers and string literals as arrays of character literals.
# The strings therefore appear in the file with a zero byte after each
# character. See the "MPLAB XC16 C Compiler User's Guide" (DS50002071E)
# section 8.9 "Literal Constant Types and Formats".
#
# In the final executable file that issue is resolved as by that point
# the compiler has optimized the 16-bit character literals down to 8-bit
# values. `strings` still doesn't work, however. Program memory on the
# 16-bit MCUs uses 24-bit words but is addressed on 16-bit boundaries.
# Each program word therefore has an extra addressable byte which
# doesn't actually exist. In the executable file that byte is included
# and always zero, so string literals are written as groups of three
# characters separated by zero bytes.
#
#
# We therefore have to implement compiler version detection ourselves.
# Fortunately that's quite easy as we know we're dealing with XC16 and
# it has a `--version` switch that produces both the GCC anc XC16
# version numbers. We still allow CMake's feature detection and test
# routines to run as they still find some useful information.


find_program(CMAKE_C_COMPILER "xc16-gcc")


# bypass CMake compiler detection
set(CMAKE_C_COMPILER_ID_RUN 1)

# set the compiler ID manually
set(CMAKE_C_COMPILER_ID GNU)
set(MICROCHIP_C_COMPILER_ID XC16)
set(CMAKE_COMPILER_IS_GNUCC 1)

# call the compiler to check its version
function(_xc16_get_version)
    execute_process(
        COMMAND "${CMAKE_C_COMPILER}" "--version"
        OUTPUT_VARIABLE output
        ERROR_VARIABLE  output
        RESULT_VARIABLE result
    )

    if(result)
        message(FATAL_ERROR
            "Calling '${CMAKE_C_COMPILER} --version' failed."
        )
    endif()

    if(output MATCHES "([0-9]+[.0-9]+).*XC16, Microchip v([0-9]+\.[0-9]+)")
        set(gnu_version  ${CMAKE_MATCH_1})
        set(xc16_version ${CMAKE_MATCH_2})
    else()
        message(FATAL_ERROR
            "Failed to parse output of '${CMAKE_C_COMPILER} --version'."
        )
    endif()

    string(REPLACE "_" "." gnu_version  ${gnu_version})
    string(REPLACE "_" "." xc16_version ${xc16_version})

    set(CMAKE_C_COMPILER_VERSION ${gnu_version} PARENT_SCOPE)
    set(MICROCHIP_C_COMPILER_VERSION ${xc16_version} PARENT_SCOPE)
endfunction()
_xc16_get_version()

# set the default C standard manually
# this is required by `Compiler/Gnu-C`
set(CMAKE_C_STANDARD_COMPUTED_DEFAULT 90)


add_compile_options(
    "-mcpu=${MICROCHIP_MCU_MODEL}"
)
string(APPEND CMAKE_C_LINK_FLAGS
    " -mcpu=${MICROCHIP_MCU_MODEL}"
    " -Wl,--script,p${MICROCHIP_MCU_MODEL}.gld"
)
