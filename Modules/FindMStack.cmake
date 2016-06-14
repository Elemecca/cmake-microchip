#.rst:
# FindMStack
# -----------
#
# Finds the M-Stack USB stack for Microchip PIC MCUs.
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
