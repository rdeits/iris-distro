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

# We have to grab this value *outside* the function call, see: http://stackoverflow.com/a/12854575/641846
set(PATH_TO_SWIG_MATLAB ${CMAKE_CURRENT_LIST_DIR})

function(add_swig_matlab_module)
	# Parse our arguments and make sure we got the required ones
	set(options CPLUSPLUS)
	set(oneValueArgs SWIG_I_FILE TARGET DESTINATION )
	set(multiValueArgs INCLUDE_DIRS LINK_LIBRARIES SWIG_INCLUDE_DIRS)
	cmake_parse_arguments(swigmat "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
	if (NOT swigmat_MODULE)
		message(FATAL_ERROR "Error using add_swig_matlab_module: Please provide the SWIG module name with 'MODULE modulename'")
	endif()
	if (NOT swigmat_SWIG_I_FILE)
		message(FATAL_ERROR "Error using add_swig_matlab_module: Please provide the full path to your .i file with 'SWIG_I_FILE filepath'")
	endif()

	if (NOT MATLAB_ROOT)
		message(FATAL_ERROR "Please run 'mex_setup(REQUIRED)' which is provided by mex.cmake in https://github.com/RobotLocomotion/cmake before using this macro.")
	endif()

	include_directories(${MATLAB_ROOT}/extern/include ${MATLAB_ROOT}/simulink/include )

	# Load the swig macros
	if (NOT SWIG_EXECUTABLE)
		find_package(SWIG REQUIRED)
		include(UseSWIGMatlab)
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
	set_source_files_properties(${swigmat_SWIG_I_FILE} PROPERTIES
		CPLUSPLUS ${CPLUSPLUS}
		)

	# Tell swig to also look for .i interface files in these folders
	foreach(dir IN LISTS swigmat_SWIG_INCLUDE_DIRS)
		set(CMAKE_SWIG_FLAGS ${CMAKE_SWIG_FLAGS} "-I${dir}")
	endforeach(dir)

	# Tell swig to build matlab bindings for our target library and link them against the C++ library. 
	if (swigmat_DESTINATION)
		set(CMAKE_SWIG_OUTDIR ${swigmat_DESTINATION})
	endif()
	swig_add_module(${swigmat_MODULE} matlab ${swigmat_SWIG_I_FILE} ${PATH_TO_SWIG_MATLAB}/Matlabdef.def)
	swig_link_libraries(${swigmat_MODULE} ${swigmat_LINK_LIBRARIES})

	# add_definitions(/DMATLAB_MEX_FILE) #define matlab macros
	# add_definitions(/DMX_COMPAT_32)

	# if(WIN32) # 32-bit or 64-bit mex
	# 	if (CMAKE_CL_64)
	# 	    SET_TARGET_PROPERTIES(${swigmat_MODULE} PROPERTIES PREFIX "" SUFFIX .mexw64)
	# 	else()
	# 	    SET_TARGET_PROPERTIES(${swigmat_MODULE} PROPERTIES SUFFIX .mexw32)
	# 	endif()
	# else()
	# 	if (APPLE)
	# 	    if (CMAKE_SIZEOF_VOID_P MATCHES "8")
	# 	        SET_TARGET_PROPERTIES(${swigmat_MODULE} PROPERTIES PREFIX "" SUFFIX .mexmaci64 PREFIX "")
	# 	    elseif((${BITNESS} EQUAL "64"))
	# 	        SET_TARGET_PROPERTIES(${swigmat_MODULE} PROPERTIES PREFIX "" SUFFIX .mexmaci32 PREFIX "")
	# 	    endif()
	# 	else()
	# 	    if (CMAKE_SIZEOF_VOID_P MATCHES "8")
	# 	        SET_TARGET_PROPERTIES(${swigmat_MODULE} PROPERTIES PREFIX "" SUFFIX .mexa64 PREFIX "")
	# 	    else()
	# 	        SET_TARGET_PROPERTIES(${swigmat_MODULE} PROPERTIES PREFIX "" SUFFIX .mexglx PREFIX "")
	# 	    endif()
	# 	endif()
	# endif()


	# Set a variable in the scope of the cmake file that called this function so that it can be referenced later (for example, to 
	set(SWIG_MODULE_${swigmat_MODULE}_REAL_NAME ${SWIG_MODULE_${swigmat_MODULE}_REAL_NAME} PARENT_SCOPE)

	if (swigmat_DESTINATION)
		install(TARGETS ${SWIG_MODULE_${swigmat_MODULE}_REAL_NAME} DESTINATION ${swigmat_DESTINATION})
	endif()
endfunction()
