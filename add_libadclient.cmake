function(add_libadclient)
	add_library(RuBackup::libadclient STATIC IMPORTED)
	ExternalProject_Add(libadclient_ext
		GIT_REPOSITORY    http://10.177.32.32/env/libraries/libadclient.git
		GIT_TAG           rb_adaptation
		SOURCE_DIR        ""
		BUILD_IN_SOURCE   1
		CONFIGURE_COMMAND ""
		BUILD_COMMAND     make
		INSTALL_COMMAND   ""
		TEST_COMMAND      ""
		UPDATE_COMMAND    ""
		EXCLUDE_FROM_ALL TRUE
	)
	ExternalProject_Get_Property(libadclient_ext SOURCE_DIR)
	create_libadclient_include_dir(${SOURCE_DIR} "include" libadclient_include_dir)
	set_target_properties(RuBackup::libadclient
		PROPERTIES
			INTERFACE_INCLUDE_DIRECTORIES ${SOURCE_DIR}/include
			IMPORTED_LOCATION ${SOURCE_DIR}/lib/libadclient.a
	)
	add_dependencies(RuBackup::libadclient libadclient_ext)
endfunction()

function(create_libadclient_include_dir ROOT_DIR DIR_PATH INC_DIR)
	execute_process(COMMAND mkdir -p ${DIR_PATH}
		WORKING_DIRECTORY ${ROOT_DIR}
	)
	set(${INC_DIR} ${ROOT_DIR}/${DIR_PATH} PARENT_SCOPE)
endfunction()