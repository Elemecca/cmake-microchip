find_package(Java COMPONENTS Runtime)

set(IPECMD ${Java_JAVA_EXECUTABLE} -jar "/opt/microchip/mplabx/v3.35/mplab_ipe/ipecmd.jar")
set(IPE_LOG MPLABXLog.xml MPLABXLog.xml.0 MPLABXLog.xml.1 MPLABXLog.xml.2 MPLABXLog.xml.3 MPLABXLog.xml.4 MPLABXLog.xml.5 MPLABXLog.xml.6 MPLABXLog.xml.7)

function(finIPE)

endfunction()
function(ipeDeploit target)

    find_program(MICROCHIP_IPECMD
        NAMES ${IPECMD}
        HINTS ${_CMAKE_TOOLCHAIN_LOCATION}
    )

    if(NOT MICROCHIP_IPECMD)
        message(SEND_ERROR "No ipecmd.jar program was found")
    endif()

    add_custom_command(
        DEPENDS ${target}
        COMMAND ${IPECMD} -f${target}.hex -M -P${MICROCHIP_MCU_MODEL} -TPICD3 -Y
        OUTPUT log.0
        BYPRODUCTS ${IPE_LOG}
        COMMENT "Deploit to pic32"
        VERBATIM
    )
    add_custom_target(deploit DEPENDS log.0)
endfunction()

function(ipeRun target device)
    
    add_custom_target(run DEPENDS deploit
        COMMAND ${IPECMD} -f${target}.hex -P${MICROCHIP_MCU_MODEL} -TPICD3 -Y -Q
        COMMAND sh -c "cat ${device} | sed '/^\\s*$/d'"
        VERBATIM
    )
endfunction()
