
## Versions

In XC8 version 2.00, Microchip switched from their proprietary HI-TECH C
frontend to Clang in order to support C99. Rather than implement PIC
code generation in LLVM, they translate LLVM's IR to p-code (the HI-TECH
IR), which is then run through the same code generator used with the old
HI-TECH frontend. Although they use Clang by default, current versions
of XC8 still include the HI-TECH C frontend to support older projects.
They've also bundled in AVR-GCC to support AVR parts.

### Command-line Driver

Since they now need to support multiple compilers, Microchip also
introduced a new command-line driver, `xc8-cc`, in XC8 2.00.  `xc8-cc`
is completely custom, but it uses GCC-style options for compatibility
with XC16 and XC32. The old command-line driver `xc8` was retained for
backwards compatibility.

You can select which command-line driver to use by setting
`MICROCHIP_XC8_CLI` to either `xc8-cc`, `xc8` or `avr-gcc` in your `CMakeLists.txt`
before calling the `project` command (which is when compiler resolution
occurs). For example:

```cmake
# set up the Microchip cross toolchain
set(CMAKE_TOOLCHAIN_FILE external/cmake-microchip/toolchain.cmake)

# set the default MCU model
set(MICROCHIP_MCU PIC18F87J50)

# use the new command-line driver
set(MICROCHIP_XC8_CLI xc8-cc)


project(example C)
```

`MICROCHIP_XC8_CLI` may also be set on the command line as a cache
variable, although doing so may break your project if you use
command-line flags in your configuration that are specific to one of the
drivers. For example:

```plain
cmake -DMICROCHIP_XC8_CLI=xc8 -DMICROCHIP_XC8_PATH=/opt/microchip/xc8/v1.45 .
```

For new projects it is recommended to use `xc8-cc`, which is the default
in cmake-microchip as of version 0.3. Using `xc8-cc` is required if you
want to use Clang (for C99) or AVR-GCC.

Using the legacy `xc8` command-line driver is only recommended if you
need to support versions of XC8 before 2.00, or if you have a significant
number of command-line flags for `xc8` already and don't want to port
them. It is *not* necessary to use `xc8` in order to use the old HI-TECH
C frontend.
