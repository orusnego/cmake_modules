include(add_nlohmann_json)
include(add_curlpp)

function(add_libminio INC_DIR LIB_PATH)
    add_library(RuBackup::libminio STATIC IMPORTED)
  
    #Try to find it in custom paths provided to cmake command
    if((NOT ${LIB_PATH}) OR (NOT ${INC_DIR}))
        message("Path to libmino wasn't defined. \n It will be build along with and exclusivly for this project. \n To specify custom path to the library use ${LIB_PATH} variable")

        add_nlohmann_json()
        add_curlpp()

        cmake_host_system_information(RESULT CORE_NUMBERS
                                      QUERY NUMBER_OF_LOGICAL_CORES)
        if(NOT CORE_NUMBERS EQUAL 0)
            set(JOBS_NUMBER ${CORE_NUMBERS})
        else()
            set(JOBS_NUMBER 4)
        endif()

        ExternalProject_Add(libminio_ext
          GIT_REPOSITORY    git@github.com:orusnego/minio.git
          GIT_TAG           main
          SOURCE_DIR        ""
          UPDATE_COMMAND ""
          UPDATE_DISCONNECTED 1
          CMAKE_ARGS        -DCURLPP_LIB_PATH=${CURLPP_LIB_PATH} -DCURLPP_INCLUDE_PATH=${CURLPP_INCLUDE_PATH} -DNLOHMANN_JSON_INCLUDE_PATH=${NLOHMANN_JSON_INCLUDE_PATH} -DBUILD_EXAMPLES=OFF -DBUILD_TESTS=OFF -DBUILD_DOC=OFF
          BUILD_COMMAND     make -j ${JOBS_NUMBER}
          INSTALL_COMMAND   ""
          TEST_COMMAND      ""
          EXCLUDE_FROM_ALL TRUE
        )
        add_dependencies(libminio_ext nlohmann_json_ext)
        add_dependencies(libminio_ext curlpp_ext)
        

        ExternalProject_Get_Property(libminio_ext SOURCE_DIR)
        ExternalProject_Get_Property(libminio_ext BINARY_DIR)

        create_libminio_include_dir(${SOURCE_DIR} "headers" libminio_include_dir)
        add_custom_command(TARGET libminio_ext POST_BUILD
                           COMMAND ${CMAKE_COMMAND} -E make_directory ${libminio_include_dir}/minio 
                           COMMAND ${CMAKE_COMMAND} -E copy_directory ${SOURCE_DIR}/include ${libminio_include_dir}/minio
        )
        set_target_properties(RuBackup::libminio
            PROPERTIES
                INTERFACE_INCLUDE_DIRECTORIES "${libminio_include_dir};${NLOHMANN_JSON_INCLUDE_PATH}"
                IMPORTED_LOCATION ${BINARY_DIR}/src/libminiocpp.a
        )
        add_dependencies(RuBackup::libminio libminio_ext)
    else()
        set_target_properties(RuBackup::libminio
            PROPERTIES
                INTERFACE_INCLUDE_DIRECTORIES ${${INC_DIR}}
                IMPORTED_LOCATION ${${LIB_PATH}}
        )
    endif()
    
    # build fix for gcc 8
    if (${TARGET_OS} MATCHES astra_1.7 OR
        ${TARGET_OS} MATCHES centos_8 OR
        ${TARGET_OS} MATCHES oracle_8.8 OR
        ${TARGET_OS} MATCHES redos_7.3 OR
        ${TARGET_OS} MATCHES debian_10
    )
    	set_target_properties(RuBackup::libminio PROPERTIES INTERFACE_LINK_LIBRARIES stdc++fs)        
    endif()
    
endfunction()

function(create_libminio_include_dir ROOT_DIR DIR_PATH INC_DIR)
    execute_process(COMMAND mkdir -p ${DIR_PATH}
        WORKING_DIRECTORY ${ROOT_DIR}
    )
    set(${INC_DIR} ${ROOT_DIR}/${DIR_PATH} PARENT_SCOPE)
endfunction()
