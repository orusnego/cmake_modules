list(APPEND libgtest_os_list
        "ubuntu_18.04"
        "ubuntu_20.04"
        "astra_1.7"
        "astra_1.6"
)

function(add_gtest INC_DIR LIB_PATH)
    if("${TARGET_OS}" IN_LIST libgtest_os_list)
        add_library(RuBackup::gtest_main STATIC IMPORTED)
        add_library(RuBackup::gmock_main STATIC IMPORTED)

        #Try to find it in custom paths provided to cmake command
        if((NOT ${LIB_PATH}) OR (NOT ${INC_DIR}))
            message("Path to libgtest or liblzma headers wasn't defined.\n It will be build along with and exclusivly for this project.\n To specify custom path to the library use ${LIB_PATH} and ${INC_DIR} variables")


            ExternalProject_Add(libgtest_ext
                    GIT_REPOSITORY    http://10.177.32.32/env/libraries/googletest.git
                    GIT_TAG           main
                    SOURCE_DIR        ""
                    BUILD_IN_SOURCE   1
                    CONFIGURE_COMMAND cmake . -DCMAKE_INSTALL_PREFIX:PATH=install -DCMAKE_INSTALL_LIBDIR:PATH=lib -DCMAKE_BUILD_TYPE=Release
                    BUILD_COMMAND     make
                    INSTALL_COMMAND   make install
                    TEST_COMMAND      ""
                    UPDATE_COMMAND ""
                    EXCLUDE_FROM_ALL TRUE
                    )
            ExternalProject_Get_Property(libgtest_ext SOURCE_DIR)
            create_libgtest_include_dir(${SOURCE_DIR} "install/include" libgtest_include_dir)
            set_target_properties(RuBackup::gmock_main
                    PROPERTIES
                    INTERFACE_INCLUDE_DIRECTORIES "${libgtest_include_dir}"
                    IMPORTED_LOCATION ${SOURCE_DIR}/install/lib/libgmock.a
                    )
            set_target_properties(RuBackup::gtest_main
                    PROPERTIES
                    INTERFACE_INCLUDE_DIRECTORIES "${libgtest_include_dir}"
                    IMPORTED_LOCATION ${SOURCE_DIR}/install/lib/libgtest.a
                    )
            add_dependencies(RuBackup::gtest_main libgtest_ext)
            add_dependencies(RuBackup::gmock_main libgtest_ext)
        else()
            set_target_properties(RuBackup::libgtest
                    PROPERTIES
                    INTERFACE_INCLUDE_DIRECTORIES ${${INC_DIR}}
                    IMPORTED_LOCATION ${${LIB_PATH}}
                    )
        endif()
    endif()
endfunction()

function(create_libgtest_include_dir ROOT_DIR DIR_PATH INC_DIR)
    execute_process(COMMAND mkdir -p ${DIR_PATH}
        WORKING_DIRECTORY ${ROOT_DIR}
    )
    set(${INC_DIR} ${ROOT_DIR}/${DIR_PATH} PARENT_SCOPE)
endfunction()
