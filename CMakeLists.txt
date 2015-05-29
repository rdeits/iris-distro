cmake_minimum_required(VERSION 2.6.0)

# pull in the pods macros. See cmake/pods.cmake for documentation
set(POD_NAME iris)
include(cmake/pods.cmake)

if (CMAKE_COMPILER_IS_GNUCC)
   set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wreturn-type -Wuninitialized -Wunused-variable") # -Wunused-parameter")

   execute_process(COMMAND ${CMAKE_C_COMPILER} -dumpversion
                OUTPUT_VARIABLE GCC_VERSION)
   if (NOT (GCC_VERSION VERSION_GREATER 4.3 OR GCC_VERSION VERSION_EQUAL 4.3))
        message(FATAL_ERROR "requires gcc version >= 4.3")  # to support the c++0x flag below
   elseif(GCC_VERSION VERSION_LESS 4.7)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x")
   else()
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
   endif()
elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
   set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wreturn-type -Wuninitialized -Wunused-variable") # -Wunused-parameter")

  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
 if (APPLE)  # this was a step towards getting things to work with
#   clang on mac, but ultimately we didn't get there...   (but I would
#   be worried about sharing pointers between objects compiled against
#   different c++ libs, so removing it)
#    # http://stackoverflow.com/questions/13445742/apple-and-shared-ptr
   set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -stdlib=libc++")
  endif()
elseif (MSVC)
#  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /arch:SSE2 /openmp")
#  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /arch:SSE2 /openmp")

  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /wd4251")
    # disable warning C4251: e.g.'RigidBody::linkname' : class 'std::basic_string<_Elem,_Traits,_Ax>' needs to have dll-interface to be used by clients of class 'RigidBody'
    # followed by template linking errors.  After reading, e.g.:
    #   https://connect.microsoft.com/VisualStudio/feedback/details/696593/vc-10-vs-2010-basic-string-exports
    # I think we're not being sufficiently careful with our library interfaces (on other platforms as well) - Russ

  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /wd4996") # disable sprintf security warning
endif()

# require python
find_package(PythonInterp REQUIRED)

# install all python files in the python/ subdirectory
pods_install_python_packages(${CMAKE_CURRENT_SOURCE_DIR}/python)

# install a script "hello-python" that runs the hello.main python module
# This script gets installed to ${CMAKE_INSTALL_PREFIX}/bin/hello-python
# and automatically sets the correct python path.
# pods_install_python_script(hello-python hello.main)

# setup matlab pods-compliance
include(cmake/matlab_pods.cmake)
pods_configure_matlab_paths()

get_relative_path("${CMAKE_INSTALL_PREFIX}/matlab" "${CMAKE_CURRENT_SOURCE_DIR}/matlab" relpath)

message(STATUS "Writing addpath_iris.m and rmpath_iris.m to ${CMAKE_INSTALL_PREFIX}/matlab")
file(WRITE ${CMAKE_INSTALL_PREFIX}/matlab/addpath_iris.m
	   "function addpath_iris()\n"
	   "  mfiledir = fileparts(which(mfilename));\n"
	   "  wd = cd(fullfile(mfiledir,'${relpath}'));\n"
	   "  addpath_iris();\n"
	   "  cd(wd);\n"
    )

file(WRITE ${CMAKE_INSTALL_PREFIX}/matlab/rmpath_iris.m
	   "function rmpath_iris()\n"
	   "  mfiledir = fileparts(which(mfilename));\n"
	   "  wd = cd(fullfile(mfiledir,'${relpath}'));\n"
	   "  rmpath_iris();\n"
	   "  cd(wd);\n"
    )

pods_find_pkg_config(eigen3 3.2)

if (eigen3_FOUND)
   pods_use_pkg_config_includes( eigen3 )
else()
   # then use the traditional approach to finding Eigen3
   find_package( Eigen3 3.2 )
   if (Eigen3_FOUND)
      set(eigen3_FOUND 1)
      include_directories( EIGEN3_INCLUDE_DIR )
   else()
      message(FATAL_ERROR "Could not find eigen, which is a required depedency")
   endif()
endif()

add_subdirectory(cvxgen)
add_subdirectory(src)