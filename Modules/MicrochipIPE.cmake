
include(MicrochipPathSearch)

find_package(Java COMPONENTS Runtime)

#set(IPECMD ${Java_JAVA_EXECUTABLE} -jar "/opt/microchip/mplabx/v3.35/mplab_ipe/ipecmd.jar")
set(IPE_LOG MPLABXLog.xml MPLABXLog.xml.0 MPLABXLog.xml.1 MPLABXLog.xml.2 MPLABXLog.xml.3 MPLABXLog.xml.4 MPLABXLog.xml.5 MPLABXLog.xml.6 MPLABXLog.xml.7)

function(finMPLABX)
    MICROCHIP_PATH_SEARCH(MICROCHIP_MPLABX_PATH mplabx
        CACHE "the path to a Microchip MPLABX installation"
    )
    
    
    if(NOT MICROCHIP_MPLABX_PATH)
        message(FATAL_ERROR
            "No Microchip MPLABX was found. Please provide the path"
            " to an MPLABX installation on the command line, for example:\n"
            "cmake -DMICROCHIP_MPLABX_PATH=/opt/microchip/mplabx/v1.42 ."
        )
    endif()
endfunction()
function(add_ipe_deploit_target target)

    finMPLABX()

    find_program(MICROCHIP_IPECMD
        NAMES mplab_ipe/ipecmd.jar
        HINTS ${MICROCHIP_MPLABX_PATH}
    )

    if(NOT MICROCHIP_IPECMD)
        message(SEND_ERROR "No ipecmd.jar program was found")
    endif()
    set(IPECMD ${Java_JAVA_EXECUTABLE} -jar ${MICROCHIP_IPECMD})

    add_custom_command(
        DEPENDS ${target}.hex
        COMMAND ${IPECMD} -f${target}.hex -M -P${MICROCHIP_MCU_MODEL} -TPICD3 -Y
        OUTPUT log.0
        BYPRODUCTS ${IPE_LOG}
        COMMENT "Deploit to pic32"
        VERBATIM
    )
    add_custom_target(deploit DEPENDS log.0)
endfunction()

function(ipeRestar target)
    finMPLABX()

    find_program(MICROCHIP_IPECMD
        NAMES mplab_ipe/ipecmd.jar
        HINTS ${MICROCHIP_MPLABX_PATH}
    )

    if(NOT MICROCHIP_IPECMD)
        message(SEND_ERROR "No ipecmd.jar program was found")
    endif()
    set(IPECMD ${Java_JAVA_EXECUTABLE} -jar ${MICROCHIP_IPECMD})
    
    add_custom_target(restart DEPENDS deploit
        COMMAND ${IPECMD} -f${target}.hex -P${MICROCHIP_MCU_MODEL} -TPICD3 -Y
        VERBATIM
    )
endfunction()

function(ipeRun target device)
    finMPLABX()

    find_program(MICROCHIP_IPECMD
        NAMES mplab_ipe/ipecmd.jar
        HINTS ${MICROCHIP_MPLABX_PATH}
    )

    if(NOT MICROCHIP_IPECMD)
        message(SEND_ERROR "No ipecmd.jar program was found")
    endif()

    set(IPECMD ${Java_JAVA_EXECUTABLE} -jar ${MICROCHIP_IPECMD})
  
    add_custom_target(run DEPENDS deploit
        #COMMAND sh -c "cat ${device} | sed '/^\\s*$/d'"
        COMMAND sh -c "cat ${device}"
        VERBATIM
    )
endfunction()
