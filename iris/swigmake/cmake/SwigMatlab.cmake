# Copyright (c) 2015, Robin Deits
# All rights reserved.

# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of the copyright holder nor the
#       names of its contributors may be used to endorse or promote products
#       derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


include(CMakeParseArguments)

function(add_swig_matlab_module target i_file)
	# Parse our arguments and make sure we got the required ones
	set(options CPLUSPLUS)
	set(oneValueArgs DESTINATION )
	set(multiValueArgs INCLUDE_DIRS LINK_LIBRARIES SWIG_INCLUDE_DIRS)
	cmake_parse_arguments(swigmat "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
	if (NOT target)
		message(FATAL_ERROR "Error using add_swig_matlab_module: Please provide a unique cmake target name as the first argument")
	endif()
	if (NOT i_file)
		message(FATAL_ERROR "Error using add_swig_matlab_module: Please provide the path to your .i file as the second argument")
	endif()

	if (NOT MATLAB_ROOT)
		message(FATAL_ERROR "Please run 'mex_setup(REQUIRED)' which is provided by mex.cmake in https://github.com/RobotLocomotion/cmake before using this macro.")
	endif()

	# Load the swig macros
	if (NOT SWIG_EXECUTABLE)
		find_package(SWIG REQUIRED)
		include(DrakeUseSWIG)
	endif()

	# Include any source directories that swig will need to find our c++ header files
	foreach(dir IN LISTS swigmat_INCLUDE_DIRS)
		include_directories(${dir})
	endforeach(dir)

	# Tell SWIG that we're compiling a c++ (not c) file, and tell it to use python3 if appropriate. 
	if (swigmat_CPLUSPLUS)
		set(CPLUSPLUS ON)
	else()
		set(CPLUSPLUS OFF)
	endif()
	set_source_files_properties(${i_file} PROPERTIES
		CPLUSPLUS ${CPLUSPLUS}
		)

	# Tell swig to also look for .i interface files in these folders
	foreach(dir IN LISTS swigmat_SWIG_INCLUDE_DIRS)
		set(CMAKE_SWIG_FLAGS ${CMAKE_SWIG_FLAGS} "-I${dir}")
	endforeach(dir)


	# Tell swig to build matlab bindings for our target library and link them against the C++ library. 
	if (swigmat_DESTINATION)
		if (IS_ABSOLUTE ${swigmat_DESTINATION})
			set(CMAKE_SWIG_OUTDIR ${swigmat_DESTINATION})
		else()
			set(CMAKE_SWIG_OUTDIR ${CMAKE_INSTALL_PREFIX}/${swigmat_DESTINATION})
		endif()
	endif()
	swig_add_module(${target} matlab ${i_file})
	swig_link_libraries(${target} ${swigmat_LINK_LIBRARIES})

	set_target_properties(${SWIG_MODULE_${target}_REAL_NAME} PROPERTIES 
			OUTPUT_NAME ${SWIG_GET_EXTRA_OUTPUT_FILES_module_basename}MEX
	        ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
	        LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
		)

	if (swigmat_DESTINATION)
		install(TARGETS ${SWIG_MODULE_${target}_REAL_NAME} DESTINATION ${swigmat_DESTINATION})
		# foreach(file IN LISTS swig_extra_generated_files)
		# 	install(FILES ${file} DESTINATION ${swigmat_DESTINATION})
		# endforeach(file)
	endif()
endfunction()
