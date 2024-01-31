
function(add_leveldb INC_DIR LIB_PATH)
        add_library(RuBackup::leveldb STATIC IMPORTED)

        #Try to find it in custom paths provided to cmake command
        if((NOT ${LIB_PATH}) OR (NOT ${INC_DIR}))
            message("Path to leveldb or leveldb headers wasn't defined.\n It will be build along with and exclusivly for this project.\n To specify custom path to the library use ${LIB_PATH} and ${INC_DIR} variables")

            set(binary_name libleveldb.a)


            if (${TARGET_OS} MATCHES windows_server_2016)
                set(config_command cmake -G "MSYS Makefiles" -DLEVELDB_BUILD_TESTS=OFF -DLEVELDB_BUILD_BENCHMARKS=OFF -DCMAKE_INSTALL_PREFIX:PATH=install -DCMAKE_INSTALL_LIBDIR:PATH=lib64 -DCMAKE_BUILD_TYPE=Release .)
            else()
                set(config_command cmake -DLEVELDB_BUILD_TESTS=OFF -DLEVELDB_BUILD_BENCHMARKS=OFF  -DCMAKE_INSTALL_PREFIX:PATH=install -DCMAKE_INSTALL_LIBDIR:PATH=lib64 -DCMAKE_BUILD_TYPE=Release .)
            endif()

            ExternalProject_Add(leveldb_ext
                    GIT_REPOSITORY    http://10.177.32.32/env/libraries/leveldb.git
                    GIT_TAG           rb_adaptation
                    SOURCE_DIR        ""
                    BUILD_IN_SOURCE   1
                    CONFIGURE_COMMAND ${config_command}
                    BUILD_COMMAND     make
                    INSTALL_COMMAND   make install
                    TEST_COMMAND      ""
                    UPDATE_COMMAND ""
                    EXCLUDE_FROM_ALL TRUE
                    )
            ExternalProject_Get_Property(leveldb_ext SOURCE_DIR)
            create_leveldb_include_dir(${SOURCE_DIR} "install/include" leveldb_include_dir)
            set_target_properties(RuBackup::leveldb
                    PROPERTIES
                    INTERFACE_INCLUDE_DIRECTORIES "${leveldb_include_dir}"
                    IMPORTED_LOCATION ${SOURCE_DIR}/install/lib64/${binary_name}
                    )
            add_dependencies(RuBackup::leveldb leveldb_ext)
        else()
            set_target_properties(RuBackup::leveldb
                    PROPERTIES
                    INTERFACE_INCLUDE_DIRECTORIES ${${INC_DIR}}
                    IMPORTED_LOCATION ${${LIB_PATH}}
                    )
        endif()
endfunction()

function(create_leveldb_include_dir ROOT_DIR DIR_PATH INC_DIR)
    execute_process(COMMAND mkdir -p ${DIR_PATH}
        WORKING_DIRECTORY ${ROOT_DIR}
    )
    set(${INC_DIR} ${ROOT_DIR}/${DIR_PATH} PARENT_SCOPE)
endfunction()
