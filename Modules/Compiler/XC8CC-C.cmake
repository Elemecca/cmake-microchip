#=============================================================================
# Copyright 2019 Sam Hanes
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
# to configure the XC8CC compiler interface for C files
# this supports the xc8-cc CLI driver from XC8 v2.x


string(APPEND CMAKE_C_FLAGS_INIT
    # build for the configured MCU model
    " -mcpu=${MICROCHIP_MCU_MODEL}"
    # fail if the requested optimization level is forbidden by the license
    " --nofallback"
)

set(CMAKE_C_OUTPUT_EXTENSION ".p1")

set(CMAKE_C_COMPILE_OBJECT)
string(APPEND CMAKE_C_COMPILE_OBJECT
    "<CMAKE_C_COMPILER> <FLAGS> <DEFINES> <INCLUDES>"
    "   -o <OBJECT>   -c <SOURCE>"
)

set(CMAKE_C_LINK_EXECUTABLE)
string(APPEND CMAKE_C_LINK_EXECUTABLE
    "<CMAKE_C_COMPILER> <FLAGS> <CMAKE_C_LINK_FLAGS> <LINK_FLAGS>"
    "   <OBJECTS>   <LINK_LIBRARIES>"
    "   -o <TARGET>"
)

set(CMAKE_C_CREATE_STATIC_LIBRARY)
string(APPEND CMAKE_C_CREATE_STATIC_LIBRARY
    "<CMAKE_AR> -r <TARGET>"
    "   <OBJECTS> <LINK_LIBRARIES>"
)
