#=============================================================================
# Copyright 2018 Sam Hanes
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
# to provide information specific to the XC8 compiler

include(MicrochipPathSearch)
MICROCHIP_PATH_SEARCH(MICROCHIP_XC8_PATH xc8
    CACHE "the path to a Microchip XC8 installation"
)

if(NOT MICROCHIP_XC8_PATH)
    message(FATAL_ERROR
        "No Microchip XC8 compiler was found. Please provide the path"
        " to an XC8 installation on the command line, for example:\n"
        "    cmake -DMICROCHIP_XC8_PATH=/opt/microchip/xc8/v2.00 .."
    )
endif()


set(CMAKE_FIND_ROOT_PATH "${MICROCHIP_XC8_PATH}")

# skip compiler search and just use XC8
find_program(CMAKE_C_COMPILER "xc8"
    PATHS "${MICROCHIP_XC8_PATH}"
    PATH_SUFFIXES "bin"
)

if(NOT CMAKE_C_COMPILER)
    message(FATAL_ERROR
        "The XC8 compiler executable was not found, but what looks"
        " like an XC8 installation was found at:\n"
        "    ${MICROCHIP_XC8_PATH}\n"
        "Please provide the path to a working XC8 installation on the"
        " command line, for example:\n"
        "    cmake -DMICROCHIP_XC8_PATH=/opt/microchip/xc8/v2.00 .."
    )
endif()

# skip compiler ID since XC8 isn't supported by CMake's test file
set(CMAKE_C_COMPILER_ID_RUN 1)
set(CMAKE_C_COMPILER_ID "XC8")

# call the compiler to check its version
function(_xc8_get_version)
    execute_process(
        COMMAND "${CMAKE_C_COMPILER}" "--ver"
        OUTPUT_VARIABLE output
        ERROR_VARIABLE  output
        RESULT_VARIABLE result
    )

    if(result)
        message(FATAL_ERROR
            "Calling '${CMAKE_C_COMPILER} --ver' failed."
        )
    endif()

    if(output MATCHES "XC8 C Compiler V([0-9]+\.[0-9]+)")
        set(CMAKE_C_COMPILER_VERSION ${CMAKE_MATCH_1} PARENT_SCOPE)
    else()
        message(FATAL_ERROR
            "Failed to parse output of '${CMAKE_C_COMPILER} --ver'."
        )
    endif()
endfunction()
_xc8_get_version()
