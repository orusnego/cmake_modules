function(check_target_os)
	list(APPEND supported_os_targets
		ubuntu_18.04
		ubuntu_20.04
		alt_10
		alt_9
		alt_8
		astra_1.7
		astra_1.6
		centos_7
		centos_8
		oracle_8.8
		oracle_9.3
		rhel_9
		debian_10
		debian_12
		#oracle_linux
		redos_7.2
		redos_7.3
		windows_server_2016
		#mac
		rosa_7.3
		rosa_7.9
	)

	if((NOT TARGET_OS) OR (NOT ${TARGET_OS} IN_LIST supported_os_targets))
		message( FATAL_ERROR "Please specify correct TARGET_OS variable to run the build.
	  Available values are: ${supported_os_targets}
	  Example: cmake -DTARGET_OS=ubuntu_18.04 .")
	endif()
endfunction()
