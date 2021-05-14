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
set(CMAKE_PREFIX_PATH "${MICROCHIP_XC8_PATH}")

if(NOT MICROCHIP_XC8_CLI)
    set(MICROCHIP_XC8_CLI "xc8-cc")
    set(_xc8_cli_default TRUE CACHE INTERNAL "" FORCE)
endif()
set(MICROCHIP_XC8_CLI "${MICROCHIP_XC8_CLI}"
    CACHE STRING "the XC8 CLI driver to use ('xc8-cc' or 'xc8')"
)


if(MICROCHIP_XC8_CLI STREQUAL "xc8-cc")
    find_program(CMAKE_C_COMPILER "xc8-cc"
        PATHS "${MICROCHIP_XC8_PATH}"
        PATH_SUFFIXES "bin"
    )
    find_program(CMAKE_AR "xc8-ar"
        PATHS "${MICROCHIP_XC8_PATH}"
        PATH_SUFFIXES "bin"
    )
    set(_xc8_version_flag "--version")
    set(CMAKE_C_COMPILER_ID "XC8CC")
elseif(MICROCHIP_XC8_CLI STREQUAL "xc8")
    find_program(CMAKE_C_COMPILER "xc8"
        PATHS "${MICROCHIP_XC8_PATH}"
        PATH_SUFFIXES "bin"
    )
    set(_xc8_version_flag "--ver")
    set(CMAKE_C_COMPILER_ID "XC8")
else()
    message(FATAL_ERROR
        "Invalid choice '${MICROCHIP_XC8_CLI}' for MICROCHIP_XC8_CLI."
        " Please choose either 'xc8-cc' (recommended) or 'xc8'."
        " See docs/xc8.md in your cmake-microchip installation for"
        " details on this option."
    )
endif()


if(NOT CMAKE_C_COMPILER)
    if(_xc8_cli_default)
        message(WARNING
            "The XC8 command-line driver was not explicitly selected,"
            " so the newer 'xc8-cc' driver is being used. This requires"
            " XC8 version 2.00 or newer. If you want to use older versions"
            " of XC8, or if you want to use the legacy 'xc8' driver in XC8"
            " 2.00 or newer, add this line to your CMakeLists.txt before"
            " the 'project' command:\n"
            "    set(MICROCHIP_XC8_CLI xc8)\n"
            "To suppress this message when XC8 is not found but continue"
            " using the newer 'xc8-cc' driver, add this line to your"
            " CMakeLists.txt before the 'project' command:\n"
            "    set(MICROCHIP_XC8_CLI xc8-cc)\n"
            "For more information on selecting a command-line driver"
            " see docs/xc8.md in your cmake-microchip installation."
        )
    endif()

    message(FATAL_ERROR
        "The XC8 compiler executable ${MICROCHIP_XC8_CLI} was not found,"
        " but what looks like an XC8 installation was found at:\n"
        "    ${MICROCHIP_XC8_PATH}\n"
        "Please provide the path to a working XC8 installation on the"
        " command line, for example:\n"
        "    cmake -DMICROCHIP_XC8_PATH=/opt/microchip/xc8/v2.00 .."
    )
endif()

# skip compiler ID since XC8 isn't supported by CMake's test file
set(CMAKE_C_COMPILER_ID_RUN 1)

# call the compiler to check its version
function(_xc8_get_version)
    execute_process(
        COMMAND "${CMAKE_C_COMPILER}" "${_xc8_version_flag}"
        OUTPUT_VARIABLE output
        ERROR_VARIABLE  output
        RESULT_VARIABLE result
    )

    if(result)
        message(FATAL_ERROR
            "Calling '${CMAKE_C_COMPILER} ${_xc8_version_flag}' failed."
        )
    endif()

    if(output MATCHES "XC8 C Compiler V([0-9]+\.[0-9]+)")
        set(CMAKE_C_COMPILER_VERSION ${CMAKE_MATCH_1} PARENT_SCOPE)
    else()
        message(FATAL_ERROR
            "Failed to parse output of '${CMAKE_C_COMPILER} ${_xc8_version_flag}'."
        )
    endif()
endfunction()
_xc8_get_version()
