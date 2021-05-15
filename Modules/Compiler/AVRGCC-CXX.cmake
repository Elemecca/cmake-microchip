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
# to configure the AVR GCC compiler interface for C files

string(TOLOWER ${MICROCHIP_MCU_MODEL} MMCU)

string(APPEND CMAKE_CXX_FLAGS_INIT
    # build for the configured MCU model
    " -mmcu=${MMCU}"
)

set(CMAKE_CXX_OUTPUT_EXTENSION ".p1")
set(CMAKE_EXECUTABLE_SUFFIX ".elf")

set(CMAKE_CXX_COMPILE_OBJECT)
string(APPEND CMAKE_CXX_COMPILE_OBJECT
    "<CMAKE_CXX_COMPILER> <FLAGS> <DEFINES> <INCLUDES>"
    "   -o <OBJECT>   -c <SOURCE>"
)

set(CMAKE_CXX_LINK_EXECUTABLE)
string(APPEND CMAKE_CXX_LINK_EXECUTABLE
    "<CMAKE_CXX_COMPILER> <FLAGS> <CMAKE_CXX_LINK_FLAGS> <LINK_FLAGS>"
    "   <OBJECTS>   <LINK_LIBRARIES>"
    "   -o <TARGET>"
)

set(CMAKE_CXX_CREATE_STATIC_LIBRARY)
string(APPEND CMAKE_CXX_CREATE_STATIC_LIBRARY
    "<CMAKE_AR> -r <TARGET>"
    "   <OBJECTS> <LINK_LIBRARIES>"
)
