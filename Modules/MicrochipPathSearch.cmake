#=============================================================================
# Copyright 2016 Sam Hanes
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

function(MICROCHIP_PATH_SEARCH outvar target)
    set(options)
    list(APPEND oneValueArgs CACHE STORE_VERSION)
    set(multiValueArgs BAD_VERSIONS)
    cmake_parse_arguments(SEARCH
        "${options}" "${oneValueArgs}" "${multiValueArgs}"
        ${ARGN}
    )

    if(SEARCH_CACHE)
        set(${outvar} "" CACHE PATH "${SEARCH_CACHE}")
        if(${outvar})
            if(EXISTS "${${outvar}}")
                set(${outvar} "${${outvar}}" PARENT_SCOPE)
            else()
                message(FATAL_ERROR
                    "given path '${${outvar}}' does not exist"
                    " in ${outvar} (${SEARCH_CACHE})"
                )
                set(${outvar} "${outvar}-NOTFOUND" PARENT_SCOPE)
            endif()
            return()
        endif()
    endif()

    set(MICROCHIP_SEARCH_PATH ""
        CACHE STRING "the search path for Microchip tool installations"
    )

    if(CMAKE_HOST_SYSTEM MATCHES "Linux")
        list(APPEND MICROCHIP_SEARCH_PATH /opt/microchip)
    elseif(CMAKE_HOST_SYSTEM MATCHES "Windows")
        list(APPEND MICROCHIP_SEARCH_PATH
            "C:/Program Files/Microchip"
            "C:/Program Files (x86)/Microchip"
        )
    endif()

    set(candidate_paths)
    foreach(path ${MICROCHIP_SEARCH_PATH})
        if(IS_DIRECTORY "${path}/${target}")
            list(APPEND candidate_paths "${path}/${target}")
        endif()
    endforeach()

    set(best_good_path)
    set(best_good_version)
    set(best_bad_path)
    set(best_bad_version)

    set(msg "\nSearching for Microchip tool '${target}' (${outvar}):")

    foreach(path ${candidate_paths})
        file(GLOB versions RELATIVE "${path}" "${path}/v*")
        foreach(version_path ${versions})
            string(REGEX REPLACE "^v" "" version "${version_path}")

            set(type good)
            if(${version} IN_LIST SEARCH_BAD_VERSIONS)
                set(type bad)
            endif()

            string(APPEND msg
                "\n    ${type} ${version} = ${path}/${version_path}"
            )

            if(NOT best_${type}_version
                    OR version VERSION_GREATER best_${type}_version)
                set(best_${type}_version "${version}")
                set(best_${type}_path "${path}/${version_path}")
            endif()
        endforeach()
    endforeach()

    if(best_good_path)
        set(result "${best_good_path}")
        set(result_version "${best_good_version}")
    elseif(best_bad_path)
        set(result "${best_bad_path}")
        set(result_version "${best_good_version}")

        message(WARNING
            "Version ${best_bad_version} of ${target} is known"
            " to be problematic. If you encounter issues, set"
            " ${outvar} to a different version."
        )
    else()
        set(result "${outvar}-NOTFOUND")
        set(result_version "${SEARCH_STORE_VERSION}-NOTFOUND")
    endif()

    string(APPEND msg
        "\n  Best good version: ${best_good_version}"
        "\n  Best bad  version: ${best_bad_version}"
        "\n  Chose: ${result}"
    )
    file(APPEND
        "${CMAKE_BINARY_DIR}/${CMAKE_FILES_DIRECTORY}/CMakeOutput.log"
        "${msg}\n\n"
    )

    if(SEARCH_CACHE)
        set(${outvar} "${result}"
            CACHE PATH "${SEARCH_CACHE}" FORCE
        )
    endif()
    set(${outvar} "${result}" PARENT_SCOPE)

    if(SEARCH_STORE_VERSION)
        set(${SEARCH_STORE_VERSION} "${result_version}" PARENT_SCOPE)
    endif()
endfunction()
