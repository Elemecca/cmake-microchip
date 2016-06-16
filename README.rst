#################################
CMake for the Microchip Toolchain
#################################

This project provides toolchains and other support modules to enable
using `CMake`_ with the `Microchip compilers`_, although presently only
XC16 is supported.

.. _CMake: https://cmake.org/
.. _Microchip compilers: http://www.microchip.com/mplab/compilers

Usage
=====

First, you need to somehow get a copy of this project as a subdirectory
of your project named ``external/cmake-microchip``. If you use git, the
easiest way is to add a submodule::

    git submodule add git://github.com/Elemecca/cmake-microchip.git external/cmake-microchip

Then add this snippet at the very top of your ``CMakeLists.txt``::

    # make the Microchip support modules available
    list(APPEND CMAKE_MODULE_PATH
        "${CMAKE_CURRENT_SOURCE_DIR}/external/cmake-microchip/Modules"
    )

    # set up the Microchip cross toolchain
    set(CMAKE_TOOLCHAIN_FILE
        external/cmake-microchip/Toolchains/xc16.cmake
    )

The target MCU is set by the ``CMAKE_SYSTEM_PROCESSOR`` variable. It can
be set on the CMake command line like so::

    cmake -DCMAKE_SYSTEM_PROCESSOR=PIC24FJ256GB004 .

Copying
=======

This project is provided under the same BSD 3-Clause license as
CMake itself. See ``COPYING.txt`` for details.
