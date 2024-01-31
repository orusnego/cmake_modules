list(APPEND libacl_os_list
    "ubuntu_18.04"
    "ubuntu_20.04"
    "astra_1.7"
    "astra_1.6"
    "centos_7"
    "centos_8"
    "oracle_8.8"
    "oracle_9.3"
    "rhel_9"
    "redos_7.2"
    "redos_7.3"
    "alt_10"
    "alt_9"
    "alt_8"
    "rosa_7.3"
    "rosa_7.9"
)

function(add_libacl)
    if("${TARGET_OS}" IN_LIST libacl_os_list)
        unset(LIBACL_PATH CACHE)
        find_library(LIBACL_PATH acl)
        if(NOT LIBACL_PATH)
            message( FATAL_ERROR "libacl.so cannot be found")
        else()
            add_library(RuBackup::libacl SHARED IMPORTED)
            set_target_properties(RuBackup::libacl
                    PROPERTIES
                    IMPORTED_LOCATION ${LIBACL_PATH}
            )
        endif()
    endif()
endfunction()
