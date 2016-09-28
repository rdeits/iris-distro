cmake_minimum_required(VERSION 2.8.0)

if(APPLE AND POLICY CMP0042)
  cmake_policy(SET CMP0042 NEW)
endif()

set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake ${CMAKE_CURRENT_SOURCE_DIR}/swigmake/cmake ${CMAKE_MODULE_PATH} )
include(mex)
mex_setup()

include(CTest)

# pull in the pods macros. See cmake/pods.cmake for documentation
set(POD_NAME iris)
include(pods)
include(matlab_pods)

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
  if (APPLE)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -stdlib=libc++")
   endif()
elseif (MSVC)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /wd4996") # disable sprintf security warning
endif()

# install all python files in the python/ subdirectory
pods_install_python_packages(${CMAKE_CURRENT_SOURCE_DIR}/python)

set(CMAKE_LIBRARY_PATH ${CMAKE_LIBRARY_PATH} ${CMAKE_INSTALL_PREFIX}/lib)

find_package(Eigen3 REQUIRED)
include_directories( ${EIGEN3_INCLUDE_DIR} )

add_subdirectory(cvxgen)
add_subdirectory(src)
add_subdirectory(matlab/+iris)
add_subdirectory(python)

# setup matlab pods-compliance
pods_configure_matlab_paths()
pods_install_matlab_path(iris)
pods_install_bash_setup(iris "export PYTHONPATH=${CMAKE_INSTALL_PREFIX}/lib/python2.7/dist-packages:\$PYTHONPATH")
