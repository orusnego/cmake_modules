list(APPEND liblzma_os_list
        "ubuntu_18.04"
        "ubuntu_20.04"
        "alt_10"
        "alt_9"
        "alt_8"
        "astra_1.7"
        "astra_1.6"
        "centos_7"
        "centos_8"
        "oracle_8.8"
        "oracle_9.3"
        "rhel_9"
        "debian_10"
        "debian_12"
        "redos_7.2"
        "redos_7.3"
        "rosa_7.3"
        "rosa_7.9"
)

function(add_liblzma INC_DIR LIB_PATH)
    if("${TARGET_OS}" IN_LIST liblzma_os_list)
        add_library(RuBackup::liblzma STATIC IMPORTED)

        #Try to find it in custom paths provided to cmake command
        if((NOT ${LIB_PATH}) OR (NOT ${INC_DIR}))
            message("Path to liblzma or liblzma headers wasn't defined.\n It will be build along with and exclusivly for this project.\n To specify custom path to the library use ${LIB_PATH} and ${INC_DIR} variables")

            set(binary_name liblzma.a)

            cmake_host_system_information(RESULT CORE_NUMBERS
                                          QUERY NUMBER_OF_LOGICAL_CORES)
            if(NOT CORE_NUMBERS EQUAL 0)
                set(JOBS_NUMBER ${CORE_NUMBERS})
            else()
                set(JOBS_NUMBER 4)
            endif()

            ExternalProject_Add(liblzma_ext
                    GIT_REPOSITORY    http://10.177.32.32/env/libraries/xz_utils.git
                    GIT_TAG           master
                    SOURCE_DIR        ""
                    BUILD_IN_SOURCE   1
                    CONFIGURE_COMMAND cmake . -DCMAKE_INSTALL_PREFIX:PATH=install -DCMAKE_INSTALL_LIBDIR:PATH=lib64
                    BUILD_COMMAND     make -j ${JOBS_NUMBER}
                    INSTALL_COMMAND   make install
                    TEST_COMMAND      ""
                    UPDATE_COMMAND ""
                    EXCLUDE_FROM_ALL TRUE
                    )
            ExternalProject_Get_Property(liblzma_ext SOURCE_DIR)
            create_liblzma_include_dir(${SOURCE_DIR} "install/include" liblzma_include_dir)
            set_target_properties(RuBackup::liblzma
                    PROPERTIES
                    INTERFACE_INCLUDE_DIRECTORIES "${liblzma_include_dir}"
                    IMPORTED_LOCATION ${SOURCE_DIR}/install/lib64/${binary_name}
                    )
            add_dependencies(RuBackup::liblzma liblzma_ext)
        else()
            set_target_properties(RuBackup::liblzma
                    PROPERTIES
                    INTERFACE_INCLUDE_DIRECTORIES ${${INC_DIR}}
                    IMPORTED_LOCATION ${${LIB_PATH}}
                    )
        endif()
    endif()
endfunction()

function(create_liblzma_include_dir ROOT_DIR DIR_PATH INC_DIR)
    execute_process(COMMAND mkdir -p ${DIR_PATH}
        WORKING_DIRECTORY ${ROOT_DIR}
    )
    set(${INC_DIR} ${ROOT_DIR}/${DIR_PATH} PARENT_SCOPE)
endfunction()
