# CMake toolchain for the Microchip XC16 compiler
# http://www.microchip.com/mplab/compilers
#
# Copyright 2016 Sam Hanes
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# set the CMake platform
# Generic is correct for embedded systems without an OS
set(CMAKE_SYSTEM_NAME Generic)

# set the (default) MCU model
set(CMAKE_SYSTEM_PROCESSOR PIC24FJ32GB002
    CACHE STRING "the part number of the target Microchip MCU"
)

# set the (default) path to XC16
set(XC16_PATH "/opt/microchip/xc16/v1.25"
    CACHE PATH "the path at which Microchip XC16 is installed"
)

# validate the XC16 path
if(NOT EXISTS ${XC16_PATH})
    message(FATAL_ERROR
        "XC16 path '${XC16_PATH}' does not exist"
    )
endif()

# ensure that only the cross toolchain is searched for
# libraries, include files, and other similar things
set(CMAKE_FIND_ROOT_PATH ${XC16_PATH})
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

# parse the CPU option and set relevant options
if(CMAKE_SYSTEM_PROCESSOR MATCHES "^(dsPIC|PIC)([0-9]+[A-Z])([A-Z0-9]+)$")
    set(XC16_CPU_FAMILY    "${CMAKE_MATCH_1}${CMAKE_MATCH_2}")
    set(XC16_CPU_MODEL     "${CMAKE_MATCH_2}${CMAKE_MATCH_3}")
    set(XC16_SUPPORT_DIR   "${XC16_PATH}/support/${XC16_CPU_FAMILY}")
    set(XC16_LINKER_SCRIPT "p${XC16_CPU_MODEL}.gld")
    set(XC16_GLD_PATH      "${XC16_SUPPORT_DIR}/gld/${XC16_LINKER_SCRIPT}")

    if(NOT EXISTS ${XC16_GLD_PATH})
        message(SEND_ERROR
            "CPU '${CMAKE_SYSTEM_PROCESSOR}' is not supported: "
            "linker script '${XC16_GLD_PATH}' does not exist."
        )
    endif()

    add_compile_options(
        "-mcpu=${XC16_CPU_MODEL}"
    )

    set(CMAKE_C_LINK_FLAGS
        "-mcpu=${XC16_CPU_MODEL} -Wl,--script,${XC16_LINKER_SCRIPT}"
    )
else()
    message(SEND_ERROR
        "Invalid CMAKE_SYSTEM_PROCESSOR value '${CMAKE_SYSTEM_PROCESSOR}'."
    )
endif()


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
