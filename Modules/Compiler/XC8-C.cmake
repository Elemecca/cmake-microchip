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

# called by `CMakeCInformation`
# to configure the XC8 compiler interface for C files
# this supports the `xc8` CLI driver in XC8 1.x
# and the equivalent legacy CLI driver in XC8 2.x


set(MICROCHIP_XC8_MODE "free"
    CACHE STRING "the license mode for XC8 (pro, std, free)"
)

string(APPEND CMAKE_C_FLAGS_INIT
    # don't output the copyright notice on every invocation
    "-Q"
    # use the configured license mode and fail if it's not available
    " --mode=${MICROCHIP_XC8_MODE} --nofallback"
    # build for the configured MCU model
    " --chip=${MICROCHIP_MCU_MODEL}"
)


set(CMAKE_C_OUTPUT_EXTENSION ".p1")
set(CMAKE_STATIC_LIBRARY_SUFFIX_C ".lpp")


set(CMAKE_C_COMPILE_OBJECT)
string(APPEND CMAKE_C_COMPILE_OBJECT
    "<CMAKE_C_COMPILER> <FLAGS> <DEFINES> <INCLUDES>"
    "   -o<OBJECT>   --pass1 <SOURCE>"
)

set(CMAKE_C_LINK_EXECUTABLE)
string(APPEND CMAKE_C_LINK_EXECUTABLE
    "<CMAKE_C_COMPILER> <FLAGS> <CMAKE_C_LINK_FLAGS> <LINK_FLAGS>"
    "   <OBJECTS>   <LINK_LIBRARIES>"
    "   -o<TARGET>"
)

set(CMAKE_C_CREATE_STATIC_LIBRARY)
string(APPEND CMAKE_C_CREATE_STATIC_LIBRARY
    "<CMAKE_C_COMPILER> <FLAGS> <CMAKE_C_LINK_FLAGS> <LINK_FLAGS>"
    "   <OBJECTS>   <LINK_LIBRARIES>"
    " --output=lpp -o<TARGET>"
)
