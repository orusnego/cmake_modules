function(add_nlohmann_json)
    cmake_host_system_information(RESULT CORE_NUMBERS
                                  QUERY NUMBER_OF_LOGICAL_CORES)
    if(NOT CORE_NUMBERS EQUAL 0)
        set(JOBS_NUMBER ${CORE_NUMBERS})
    else()
        set(JOBS_NUMBER 4)
    endif()

    ExternalProject_Add(nlohmann_json_ext
          GIT_REPOSITORY    git@10.177.32.32:env/libraries/nlohmann-json.git
          GIT_TAG           master
          SOURCE_DIR        ""
          BUILD_IN_SOURCE   1
          UPDATE_COMMAND ""
          UPDATE_DISCONNECTED 1
          CONFIGURE_COMMAND cmake -DJSON_BuildTests=OFF
          BUILD_COMMAND     make -j ${JOBS_NUMBER}
          INSTALL_COMMAND   ""
          TEST_COMMAND      ""
          EXCLUDE_FROM_ALL TRUE
    )
    ExternalProject_Get_Property(nlohmann_json_ext SOURCE_DIR)
    
    create_nlohmann_json_include_dir(${SOURCE_DIR} "include" nlohmann_json_include_dir)
    set(NLOHMANN_JSON_INCLUDE_PATH ${nlohmann_json_include_dir} PARENT_SCOPE)
endfunction()

function(create_nlohmann_json_include_dir ROOT_DIR DIR_PATH INC_DIR)
    execute_process(COMMAND mkdir -p ${DIR_PATH}
        WORKING_DIRECTORY ${ROOT_DIR}
    )
    set(${INC_DIR} ${ROOT_DIR}/${DIR_PATH} PARENT_SCOPE)
endfunction()
