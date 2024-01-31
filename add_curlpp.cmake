function(add_curlpp)
    add_library(RuBackup::curlpp STATIC IMPORTED)
    
    cmake_host_system_information(RESULT CORE_NUMBERS
                                  QUERY NUMBER_OF_LOGICAL_CORES)
    if(NOT CORE_NUMBERS EQUAL 0)
        set(JOBS_NUMBER ${CORE_NUMBERS})
    else()
        set(JOBS_NUMBER 4)
    endif()

    ExternalProject_Add(curlpp_ext
          GIT_REPOSITORY    git@10.177.32.32:env/libraries/curlpp.git
          GIT_TAG           master
          SOURCE_DIR        ""
          UPDATE_COMMAND ""
          UPDATE_DISCONNECTED 1
          BUILD_IN_SOURCE   1
          BUILD_COMMAND     make -j ${JOBS_NUMBER}
          INSTALL_COMMAND   ""
          TEST_COMMAND      ""
          EXCLUDE_FROM_ALL TRUE
    )
    ExternalProject_Get_Property(curlpp_ext SOURCE_DIR)
    ExternalProject_Get_Property(curlpp_ext BINARY_DIR)

    create_curlpp_include_dir(${SOURCE_DIR} "include" curlpp_include_dir)
    
    set(CURLPP_INCLUDE_PATH ${curlpp_include_dir} PARENT_SCOPE)
    set(CURLPP_LIB_PATH ${BINARY_DIR} PARENT_SCOPE)
    
    set_target_properties(RuBackup::curlpp
         PROPERTIES
                INTERFACE_INCLUDE_DIRECTORIES "${curlpp_include_dir}"
                IMPORTED_LOCATION ${BINARY_DIR}/libcurlpp.a
    )
    add_dependencies(RuBackup::curlpp curlpp_ext)
endfunction()

function(create_curlpp_include_dir ROOT_DIR DIR_PATH INC_DIR)
    execute_process(COMMAND mkdir -p ${DIR_PATH}
         WORKING_DIRECTORY ${ROOT_DIR}
    )
    set(${INC_DIR} ${ROOT_DIR}/${DIR_PATH} PARENT_SCOPE)
endfunction()
