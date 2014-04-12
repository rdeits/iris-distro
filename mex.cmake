# Macros to handle compilation of MATLAB mex files.
#

cmake_minimum_required(VERSION 2.8.3)
# for cmake_parse_arguments

macro(get_mex_option option_name)
  # usage: get_mex_option(option_name [NAMES names_to_try_in_order REQUIRED])
  # writes MEX_${option_name} 
  set(ARG_NAMES "")
  set(ARG_REQUIRED "")
  if ( ${ARGC} GREATER 1 )
    cmake_parse_arguments(ARG "REQUIRED" "" "NAMES" ${ARGN})
  endif()
  if ( NOT ARG_NAMES )
    set(ARG_NAMES ${option_name})     
  endif()

  set(svalue "")
  foreach (name ${ARG_NAMES})
    string(REGEX MATCH "${name}[^\r\n]*" option_line ${mexv_output}) # first line containing ${name}
    if ( option_line )
       string(REGEX REPLACE "[^=:]+[=:](.*)" "\\1" value ${option_line})  # replace entire string with capturing group (after = )
       string(STRIP ${value} svalue)
       break()
    endif()
  endforeach()

  if ( svalue )
    set(MEX_${option_name} ${svalue})
    set(MEX_${option_name} ${svalue} PARENT_SCOPE)
#    message(STATUS "MEX_${option_name} = ${svalue}")
  else()
    if ( ARG_REQUIRED )
      message(FATAL_ERROR "Could not find MEX_${option_name} using mex -v")
    else()
     set(MEX_${option_name} "")
     set(MEX_${option_name} "" PARENT_SCOPE)
    endif()
  endif()
endmacro()

macro(get_mex_arguments afterstring)
  # writes MEX_${afterstring}_ARGUMENTS 

  cmake_parse_arguments(ARG "REQUIRED" "" "" ${ARGN})
  set(arguments_name MEX_${afterstring}_ARGUMENTS)

  string(REGEX MATCH "${afterstring}.*" starting_with_afterstring ${mexv_output}) # everything starting with afterstring
  if ( starting_with_afterstring )
    string(REGEX MATCH "arguments[^\r\n]*" arguments_line ${starting_with_afterstring}) # first line containing arguments
    if ( arguments_line )
      string(REGEX REPLACE "[^=]+=(.*)" "\\1" value ${arguments_line}) # replace entire string with capturing group (after =)
      string(STRIP ${value} svalue)
      set(${arguments_name} ${svalue} PARENT_SCOPE)
      # message(STATUS "${arguments_name} = ${svalue}")
    else()
      if ( ARG_REQUIRED )
        message(FATAL_ERROR "Could not find arguments line for ${afterstring} using mex -v")
      endif()
      set(${arguments_name} "" PARENT_SCOPE)
    endif()
  else()
    if (ARG_REQUIRED) 
      message(WARNING "Could not find block containing arguments for ${afterstring} using mex -v")
    endif()
    set(${arguments_name} "" PARENT_SCOPE)
  endif()
endmacro()

function(mex_setup)
  # sets the variables: MATLAB_ROOT, MEX, MEX_EXT
  #    as well as all of the mexopts

  find_program(matlab matlab)
  if ( NOT matlab )
     message(FATAL_ERROR "Could not find matlab executable")
  endif()
  if ( WIN32 )
    # matlab -n is not supported on windows (asked matlab for a work-around)
    get_filename_component(_matlab_root ${matlab} PATH)  
    get_filename_component(_matlab_root ${_matlab_root} PATH)  
  else()
    execute_process(COMMAND ${matlab} -n COMMAND grep -e "MATLAB \\+=" COMMAND cut -d "=" -f2 OUTPUT_VARIABLE _matlab_root)
  endif()
  if (NOT _matlab_root)
    message(FATAL_ERROR "Failed to extract MATLAB_ROOT")
  endif()
  string(STRIP ${_matlab_root} MATLAB_ROOT)

  find_program(mex NAMES mex mex.bat HINTS ${MATLAB_ROOT}/bin)
  if (NOT mex)
     message(FATAL_ERROR "Failed to find mex executable")
  endif()

  find_program(mexext NAMES mexext mexext.bat HINTS ${MATLAB_ROOT}/bin)
  execute_process(COMMAND ${mexext} OUTPUT_VARIABLE MEX_EXT OUTPUT_STRIP_TRAILING_WHITESPACE)
  if (NOT MEX_EXT)
     message(FATAL_ERROR "Failed to extract MEX_EXT")
  endif()

  set(MATLAB_ROOT ${MATLAB_ROOT} PARENT_SCOPE)
  set(mex ${mex} PARENT_SCOPE)
  set(MEX_EXT ${MEX_EXT} PARENT_SCOPE)

  file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/dummy.c "")
  execute_process(COMMAND ${mex} -v ${CMAKE_CURRENT_BINARY_DIR}/dummy.c OUTPUT_VARIABLE mexv_output ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE)
  if ( WIN32 )
    get_mex_option(CC NAMES COMPILER REQUIRED)
    get_mex_option(CXX NAMES COMPILER REQUIRED)
    
    get_mex_option(CFLAGS NAMES COMPFLAGS)
    get_mex_option(CXXFLAGS NAMES COMPFLAGS)
    get_mex_option(COPTIMFLAGS NAMES OPTIMFLAGS)
    get_mex_option(CXXOPTIMFLAGS NAMES OPTIMFLAGS)
    get_mex_option(CDEBUGFLAGS NAMES DEBUGFLAGS)
    get_mex_option(CXXDEBUGFLAGS NAMES DEBUGFLAGS)

    get_mex_option(LD NAMES LINKER)
    get_mex_option(LDFLAGS NAMES LINKFLAGS)
    get_mex_option(LDDEBUGFLAGS NAMES LINKDEBUGFLAGS)

    if (MSVC)
        string(REGEX REPLACE "^.*implib:\"(.*)templib.x\" .*$" "\\1" tempdir "${MEX_LDFLAGS}")
	string(REGEX REPLACE "/MAP:\"[.a-zA-Z0-9]*\"" "" MEX_LDFLAGS "${MEX_LDFLAGS}")
	set(MEX_LDFLAGS "${MEX_LDFLAGS}" PARENT_SCOPE)
#        message(STATUS MEX_LDFLAGS=${MEX_LDFLAGS})
    	if (tempdir)
       	  execute_process(COMMAND mkdir ${tempdir})
          message("Creating temporary directory: ${tempdir}")
    	endif()
    endif()
  else()
    get_mex_option(CC REQUIRED)
 
    get_mex_option(CFLAGS REQUIRED)
    get_mex_option(CXXFLAGS)
    get_mex_option(DEFINES)
    get_mex_option(MATLABMEX)
    get_mex_option(INCLUDE)
    get_mex_option(CDEBUGFLAGS)
    get_mex_option(COPTIMFLAGS)
    get_mex_option(CLIBS)
    get_mex_arguments(CC)
  
    get_mex_option(CXX NAMES CXX CC REQUIRED)
    get_mex_option(CXXDEBUGFLAGS)
    get_mex_option(CXXOPTIMFLAGS)
    get_mex_option(CXXLIBS)
    get_mex_arguments(CXX)

#  not supporting fortran yet below, so might as well comment these out
#  get_mex_option(FC)
#  get_mex_option(FFLAGS)
#  get_mex_option(FDEBUGFLAGS)
#  get_mex_option(FOPTIMFLAGS)
#  get_mex_option(FLIBS)
#  get_mex_arguments(FC)

    get_mex_option(LD REQUIRED)
    get_mex_option(LDFLAGS REQUIRED)
    get_mex_option(LINKLIBS)
    get_mex_option(LDDEBUGFLAGS)
    get_mex_option(LDOPTIMFLAGS)
    get_mex_option(LDEXTENSION NAMES LDEXTENSION LDEXT REQUIRED)
    get_mex_arguments(LD)

#  note: skipping LDCXX (and just always use LD)
  endif()

  # figure out LDFLAGS for exes and shared libraries
  set (MEXLIB_LDFLAGS ${MEX_LDFLAGS} ${MEX_LD_ARGUMENTS} ${MEX_CLIBS} ${MEX_LINKLIBS} "-ldl") # note: the -ldl here might be overkill?  so far only needed it for drake_debug_mex.  (but it has to come later in the compiler arguments, too, in order to work.
  string(REPLACE "-bundle" "" MEXLIB_LDFLAGS "${MEXLIB_LDFLAGS}") 
  string(REGEX REPLACE "[ ;][^ ;]*mexFunction.map\"*" "" MEXLIB_LDFLAGS "${MEXLIB_LDFLAGS}")  # zap the exports definition file
  string(REPLACE ";" " " MEXLIB_LDFLAGS "${MEXLIB_LDFLAGS}") 

  # note: on ubuntu, gcc did not like the MEX_CLIBS coming along with LINK_FLAGS (it only works if they appear after the  input files).  this is a nasty trick that I found online
  set(dummy_c_file ${CMAKE_CURRENT_BINARY_DIR}/dummy.c)
  add_custom_command(COMMAND ${CMAKE_COMMAND} -E touch ${dummy_c_file}
  			OUTPUT ${dummy_c_file})

  add_library(last STATIC ${dummy_c_file})
  target_link_libraries(last ${MEX_CLIBS} ${MEX_LINKLIBS})

  add_library(liblast STATIC ${dummy_c_file})
  target_link_libraries(liblast "${MEXLIB_LDFLAGS}") 

  set (MEXLIB_LDFLAGS "${MEXLIB_LDFLAGS}" PARENT_SCOPE)
  # todo: add CLIBS or CXXLIBS to LINK_FLAGS selectively based in if it's a c or cxx target (always added C above)
  
endfunction()

function(add_mex)
  # useage:  add_mex(target source1 source2 [SHARED,EXECUTABLE]) 
  # note: builds the mex file inplace (not into some build directory)
  # if SHARED is passed in, then it doesn't expect a mexFunction symbol to be defined, and compiles it to e.g., libtarget.so, for eventual linking against another mex file
  # if EXECUTABLE is passed in, then it adds an executable target, which is linked against the appropriate matlab libraries.

  list(GET ARGV 0 target)
  list(REMOVE_AT ARGV 0)

  if (NOT MATLAB_ROOT OR NOT MEX_EXT)
     message(FATAL_ERROR "MATLAB not found (or MATLAB_ROOT not properly parsed)")
  endif()

  include_directories( ${MATLAB_ROOT}/extern/include ${MATLAB_ROOT}/simulink/include )

  # todo: handle C separately from CXX?
  set (MEX_COMPILE_FLAGS "${MEX_INCLUDE} ${MEX_CXXFLAGS} ${MEX_DEFINES} ${MEX_MATLABMEX} ${MEX_CXX_ARGUMENTS}")
  if (CMAKE_BUILD_TYPE MATCHES DEBUG)
    set(MEX_COMPILE_FLAGS "${MEX_COMPILE_FLAGS} ${MEX_CXXDEBUGFLAGS}")
  elseif (CMAKE_BUILD_TYPE MATCHES RELEASE)
    set(MEX_COMPILE_FLAGS "${MEX_COMPILE_FLAGS} ${MEX_CXXOPTIMFLAGS}")    
  endif()

  list(FIND ARGV SHARED isshared)
  list(FIND ARGV EXECUTABLE isexe)
  if (isexe GREATER -1)
    list(REMOVE_ITEM ARGV EXECUTABLE)
    add_executable(${target} ${ARGV})
    get_source_file_property(lang ${ARGV} LANGUAGE) 
    set_target_properties(${target} PROPERTIES 
      COMPILE_FLAGS "${MEX_COMPILE_FLAGS}")
    target_link_libraries(${target} liblast)
  elseif (isshared GREATER -1)
    add_library(${target} ${ARGV})
    set_target_properties(${target} PROPERTIES 
      COMPILE_FLAGS "${MEX_COMPILE_FLAGS}")
    target_link_libraries(${target} liblast)
  else ()
    add_library(${target} MODULE ${ARGV})
    set_target_properties(${target} PROPERTIES 
      COMPILE_FLAGS "-DMATLAB_MEX_FILE ${MEX_COMPILE_FLAGS}" 
      PREFIX ""
      SUFFIX ".${MEX_EXT}"
      LINK_FLAGS "${MEX_LDFLAGS} ${MEX_LD_ARGUMENTS}" # -Wl,-rpath ${CMAKE_INSTALL_PREFIX}/lib"  
      LINK_FLAGS_DEBUG	"${MEX_LDDEBUGFLAGS}"
      LINK_FLAGS_RELEASE	"${MEX_LDOPTIMFLAGS}"
      ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
      LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"   
      )
    target_link_libraries(${target} last)
  endif()

endfunction()

function(get_compiler_version outvar compiler)
  if ( MSVC )
    execute_process(COMMAND ${compiler} ERROR_VARIABLE ver ERROR_STRIP_TRAILING_WHITESPACE OUTPUT_VARIABLE junk)
  else()
    separate_arguments(c_args UNIX_COMMAND ${compiler}) 
    list(APPEND c_args "-dumpversion")
    execute_process(COMMAND ${c_args} OUTPUT_VARIABLE ver OUTPUT_STRIP_TRAILING_WHITESPACE)
  endif()
  set(${outvar} ${ver} PARENT_SCOPE) 
   
endfunction()

## calls compilers with --version option and checks the output 
# calls compilers with -dumpversion and checks the output
# (because it appears that ccache messes with the --version output)
# returns TRUE if the strings match or FALSE if they don't.  
#   (note: you can use  if (outvar) to test )
# this seems to be a more robust and less complex method than trying to call xcrun -find, readlink to follow symlinks, etc.
function(compare_compilers outvar compiler1 compiler2)

  get_compiler_version(c1_ver ${compiler1})
  get_compiler_version(c2_ver ${compiler2})

  if (c1_ver AND c2_ver AND "${c1_ver}" STREQUAL "${c2_ver}")
    set(${outvar} TRUE PARENT_SCOPE)
  else()
    set(${outvar} FALSE PARENT_SCOPE)
    message(STATUS "compiler1 version string:\n${c1_ver}")
    message(STATUS "compiler2 version string:\n${c2_ver}")
  endif()

endfunction()


include(CMakeParseArguments)
mex_setup()

compare_compilers(compilers_match "${CMAKE_C_COMPILER}" "${MEX_CC}")
if (NOT compilers_match)
   message(FATAL_ERROR "Your cmake C compiler is: \"${CMAKE_C_COMPILER}\" but your mex options use: \"${MEX_CC}\".  You must use the same compilers.  You can either:\n  a) reconfigure the mex compiler by running 'mex -setup' in  MATLAB, or\n  b) Set the default compiler for cmake by setting the CC environment variable in your terminal.\n")
endif()

compare_compilers(compilers_match "${CMAKE_CXX_COMPILER}" "${MEX_CXX}")
if (NOT compilers_match)
   message(FATAL_ERROR "Your cmake CXX compiler is: \"${CMAKE_CXX_COMPILER}\" but your mex options end up pointing to: \"${MEX_CXX}\".  You must use the same compilers.  You can either:\n  a) Configure the mex compiler by running 'mex -setup' in  MATLAB, or \n  b) Set the default compiler for cmake by setting the CC environment variable in your terminal.")
endif()

# NOTE:  would like to check LD also, but it appears to be difficult with cmake  (there is not explicit linker executable variable, only the make rule), and  even my mex code assumes that LD==LDCXX for simplicity.

