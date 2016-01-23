
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR PIC24FJ256GB106)

set(XC16_PATH /opt/microchip/xc16/v1.25)
set(CMAKE_C_COMPILER ${XC16_PATH}/bin/xc16-gcc)
set(XC16_BIN2HEX ${XC16_PATH}/bin/xc16-bin2hex)

# ensure that only the cross toolchain is searched for
# libraries, include files, and other similar things
set(CMAKE_FIND_ROOT_PATH ${XC16_PATH})
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM BOTH)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
