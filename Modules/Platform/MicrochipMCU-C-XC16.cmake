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


# set the (default) path to XC16
set(MICROCHIP_XC16_PATH "/opt/microchip/xc16/v1.25"
    CACHE PATH "the path at which Microchip XC16 is installed"
)

# validate the XC16 path
if(NOT EXISTS ${MICROCHIP_XC16_PATH})
    message(FATAL_ERROR
        "XC16 path '${XC16_PATH}' does not exist"
    )
endif()

# ensure that only the cross toolchain is searched for
# tools, libraries, include files, and other similar things
set(CMAKE_FIND_ROOT_PATH ${MICROCHIP_XC16_PATH})
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM BOTH)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# set up the toolchain executables
find_program(CMAKE_C_COMPILER   xc16-gcc)
find_program(CMAKE_AR           xc16-ar)
find_program(CMAKE_LINKER       xc16-ld)
find_program(CMAKE_NM           xc16-nm)
find_program(CMAKE_OBJDUMP      xc16-objdump)
find_program(CMAKE_RANLIB       xc16-ranlib)
find_program(CMAKE_STRIP        xc16-strip)
find_program(XC16_BIN2HEX       xc16-bin2hex)

# verify the comiler was found
if(NOT CMAKE_C_COMPILER)
    message(FATAL_ERROR
        "XC16 path '${XC16_PATH}'"
        " does not contain an XC16 compiler"
    )
endif()


# verify that the MCU is supported
set(MICROCHIP_XC16_LINKER_SCRIPT "p${MICROCHIP_MCU_MODEL}.gld")
set(MICROCHIP_XC16_SUPPORT_DIR
    "${MICROCHIP_XC16_PATH}/support/${MICROCHIP_MCU_FAMILY}"
)
set(MICROCHIP_XC16_GLD_PATH
    "${MICROCHIP_XC16_SUPPORT_DIR}/gld/${MICROCHIP_XC16_LINKER_SCRIPT}"
)
if(NOT EXISTS ${MICROCHIP_XC16_GLD_PATH})
    message(SEND_ERROR
        "MCU '${MICROCHIP_MCU}' is not supported: linker script"
        " '${MICROCHIP_XC16_GLD_PATH}' does not exist."
    )
endif()


add_compile_options(
    "-mcpu=${MICROCHIP_MCU_MODEL}"
)

string(APPEND CMAKE_C_LINK_FLAGS
    " -mcpu=${MICROCHIP_MCU_MODEL}"
    " -Wl,--script,${MICROCHIP_XC16_LINKER_SCRIPT}"
)


# adds an Intel HEX conversion to the given target
function(bin2hex target)
    function(get_target_property_fallback var target)
        set(result NOTFOUND)
        foreach(property ${ARGN})
            get_target_property(result ${target} ${property})
            if(result)
                break()
            endif()
        endforeach()
        set(${var} ${result} PARENT_SCOPE)
    endfunction()

    get_target_property_fallback(in_f ${target}
        RUNTIME_OUTPUT_NAME
        OUTPUT_NAME
        NAME
    )

    get_target_property_fallback(dir ${target}
        RUNTIME_OUTPUT_DIRECTORY
        BINARY_DIR
    )

    get_filename_component(out_f ${in_f} NAME_WE)
    set(out_f "${out_f}.hex")

    add_custom_command(
        TARGET ${target} POST_BUILD
        WORKING_DIRECTORY ${dir}
        COMMAND ${XC16_BIN2HEX} ${in_f}
        COMMENT "Creating HEX for ${target}"
        BYPRODUCTS ${dir}/${out_f}
        VERBATIM
    )

    set_property(DIRECTORY APPEND
        PROPERTY ADDITIONAL_MAKE_CLEAN_FILES
            ${dir}/${out_f}
    )
endfunction()
