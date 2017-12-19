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

set(_CMAKE_TOOLCHAIN_PREFIX "xc32-")

if(NOT MICROCHIP_XC32_PATH)
    MICROCHIP_PATH_SEARCH(MICROCHIP_XC32_PATH xc32
        CACHE "the path to a Microchip XC32 installation"
        STORE_VERSION MICROCHIP_C_COMPILER_VERSION
    )
endif()


function(_xc32_get_version)
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

    if(output MATCHES "([0-9]+(\.[0-9]+)+).* MPLAB XC32 Compiler .*v([0-9]+(\.[0-9]+)+)")
        set(gnu_version  ${CMAKE_MATCH_1})
        set(xc32_version ${CMAKE_MATCH_3})
    else()
        message(FATAL_ERROR
            "Failed to parse output of '${CMAKE_C_COMPILER} --version'."
        )
    endif()

    string(REPLACE "_" "." gnu_version  ${gnu_version})
    string(REPLACE "_" "." xc32_version ${xc32_version})

    set(CMAKE_C_COMPILER_VERSION ${gnu_version} PARENT_SCOPE)
    set(MICROCHIP_C_COMPILER_VERSION ${xc32_version} PARENT_SCOPE)
endfunction()

if(NOT MICROCHIP_XC32_PATH)
    message(FATAL_ERROR
        "No Microchip XC32 compiler was found. Please provide the path"
        " to an XC32 installation on the command line, for example:\n"
        "cmake -DMICROCHIP_XC32_PATH=/opt/microchip/xc32/v1.42 ."
    )
endif()

set(CMAKE_FIND_ROOT_PATH ${MICROCHIP_XC32_PATH})

find_program(CMAKE_ASM_COMPILER "xc32-gcc")
find_program(CMAKE_C_COMPILER "xc32-gcc")
find_program(CMAKE_CXX_COMPILER "xc32-g++")

set(MICROCHIP_C_COMPILER_ID XC32)
set(CMAKE_C_STANDARD_COMPUTED_DEFAULT 90)
set(CMAKE_CXX_COMPILER_FORCED ON)


set(link_flags "")
set(compile_flags "")

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

if(CMAKE_C_COMPILER)
	_xc32_get_version()
endif()
