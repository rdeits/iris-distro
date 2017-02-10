cmake_minimum_required(VERSION 2.8.0)

if(APPLE AND POLICY CMP0042)
  cmake_policy(SET CMP0042 NEW)
endif()

if(BUILD_TESTING)
  include(CTest)
  enable_testing()
endif()

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/../cmake)

find_package(pybind11 REQUIRED)
find_package(Eigen3 REQUIRED)
find_package(PkgConfig REQUIRED)
find_package(Mosek REQUIRED)
find_package(NumPy REQUIRED)

include_directories(${NUMPY_INCLUDE_DIRS})
include_directories(${EIGEN3_INCLUDE_DIR})
include_directories(${CMAKE_INSTALL_PREFIX}/include)
link_directories(${CMAKE_INSTALL_PREFIX}/lib)

# Set RPATH for installed binaries
set(CMAKE_INSTALL_RPATH
  ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}
  ${CMAKE_INSTALL_PREFIX}/lib${LIB_SUFFIX}
  ${CMAKE_INSTALL_PREFIX}/lib)
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH ON)

list(REMOVE_DUPLICATES CMAKE_INSTALL_RPATH)

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

add_subdirectory(cxx)
add_subdirectory(python)

if(WITH_MATLAB)
  add_subdirectory(matlab)
endif()
