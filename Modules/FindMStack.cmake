#.rst:
# FindMStack
# -----------
#
# Finds the M-Stack USB stack for Microchip PIC MCUs.
#
# ########## COPYRIGHT NOTICE ##########
# CMake-Microchip - CMake support for the Microchip embedded toolchain
# Copyright 2016 Sam Hanes
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# 1. Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in the
# documentation and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its
# contributors may be used to endorse or promote products derived from
# this software without specific prior written permission.
#
# This software is provided by the copyright holders and contributors
# "as is" and any express or implied warranties, including, but not
# limited to, the implied warranties of merchantability and fitness for
# a particular purpose are disclaimed. In no event shall the copyright
# holder or contributors be liable for any direct, indirect, incidental,
# special, exemplary, or consequential damages (including, but not
# limited to, procurement of substitute goods or services; loss of use,
# data, or profits; or business interruption) however caused and on any
# theory of liability, whether in contract, strict liability, or tort
# (including negligence or otherwise) arising in any way out of the use
# of this software, even if advised of the possibility of such damage.
# ########## END COPYRIGHT NOTICE ##########


set(MStack_ROOT external/m-stack
    CACHE PATH "the root of the M-Stack source checkout"
)
get_filename_component(MStack_ROOT "${MStack_ROOT}" ABSOLUTE)

set(MStack_USB_ROOT ${MStack_ROOT}/usb)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(MStack
    REQUIRED_VARS
        MStack_ROOT
)

if(NOT MStack_FOUND)
    return()
endif()


add_library(MStack INTERFACE)
target_sources(MStack INTERFACE
    ${MStack_USB_ROOT}/src/usb.c
)
target_include_directories(MStack INTERFACE
    ${MStack_ROOT}/usb/include
)


add_library(MStack_HID INTERFACE)
target_sources(MStack_HID INTERFACE
    ${MStack_USB_ROOT}/src/usb_hid.c
)
target_link_libraries(MStack_HID
    INTERFACE MStack
)


add_library(MStack_CDC INTERFACE)
target_sources(MStack_CDC INTERFACE
    ${MStack_USB_ROOT}/src/usb_cdc.c
)
target_link_libraries(MStack_CDC
    INTERFACE MStack
)
