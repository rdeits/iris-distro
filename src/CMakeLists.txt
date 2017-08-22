cmake_minimum_required(VERSION 2.8.12)
project(iris)

if(APPLE)
  # Compiler ID for Apple Clang is now AppleClang.
  if(POLICY CMP0025)
    cmake_policy(SET CMP0025 NEW)
  endif()

  # MACOSX_RPATH is enabled by default.
  if(POLICY CMP0042)
    cmake_policy(SET CMP0042 NEW)
  endif()
endif()

include(CMakePackageConfigHelpers)
include(CTest)
include(GNUInstallDirs)

list(INSERT CMAKE_MODULE_PATH 0 "${CMAKE_CURRENT_SOURCE_DIR}/../cmake")

find_package(pybind11 CONFIG REQUIRED)
find_package(Mosek CONFIG REQUIRED)
find_package(NumPy MODULE REQUIRED)

# Newer versions of Eigen 3 define imported targets in their package
# configuration files, so try to locate such a file before using the legacy
# find module.
find_package(Eigen3 CONFIG)

if(NOT Eigen3_FOUND)
  find_package(Eigen3 MODULE REQUIRED)
endif()

find_library(CDD_LIBRARY NAMES cdd)

if(NOT CDD_LIBRARY)
  message(FATAL_ERROR "Could NOT find cdd")
endif()

find_path(CDD_INCLUDE_DIR NAMES cdd.h)

if(NOT CDD_INCLUDE_DIR)
  message(FATAL_ERROR "Could NOT find cdd.h")
endif()

# Set RPATH for installed binaries.
set(CMAKE_INSTALL_RPATH
  "${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}"
  "${CMAKE_INSTALL_PREFIX}/lib")
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH ON)

list(REMOVE_DUPLICATES CMAKE_INSTALL_RPATH)

# Check that the compiler supports a flag for setting the C++ dialect to C++0x
# or C++11.
if(CMAKE_CXX_COMPILER_ID STREQUAL "AppleClang")
  set(MIN_COMPILER_VERSION 4.0)
  set(CXX_FLAGS_CXX11 "-std=c++11")
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
  set(MIN_COMPILER_VERSION 2.1)
  if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS 3.1)
    set(CXX_FLAGS_CXX11 "-std=c++0x")
  else()
    set(CXX_FLAGS_CXX11 "-std=c++11")
  endif()
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  set(MIN_COMPILER_VERSION 4.4)
  if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS 4.7)
    set(CXX_FLAGS_CXX11 "-std=c++0x")
  else()
    set(CXX_FLAGS_CXX11 "-std=c++11")
  endif()
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "Intel")
  set(MIN_COMPILER_VERSION 12.1)
  if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS 13.0)
    if(WIN32)
      set(CXX_FLAGS_CXX11 "/Qstd=c++0x")
    else()
      set(CXX_FLAGS_CXX11 "-std=c++0x")
    endif()
  else()
    if(WIN32)
      set(CXX_FLAGS_CXX11 "/Qstd=c++11")
    else()
      set(CXX_FLAGS_CXX11 "-std=c++11")
    endif()
  endif()
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
  set(MIN_COMPILER_VERSION 1900)
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "PGI")
  set(MIN_COMPILER_VERSION 15)
  set(CXX_FLAGS_CXX11 "--c++11")
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "XL")
  set(MIN_COMPILER_VERSION 10.1)
  if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS 13.1.2)
    set(CXX_FLAGS_CXX11 "-qlanglvl=extended0x")
  else()
    set(CXX_FLAGS_CXX11 "-std=c++11")
  endif()
else()
  set(CXX_FLAGS_CXX11)
endif()

if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS MIN_COMPILER_VERSION)
  message(FATAL_ERROR
    "Minimum ${CMAKE_CXX_COMPILER_ID} C++ compiler version is ${MIN_COMPILER_VERSION}")
endif()

# If possible, use the functionality in CMake 3.1 and above (CMake 3.9 and
# above for the PGI and XL compilers) to set the compiler flag for setting the
# C++ dialect to C++0x or C++11.
if(CMAKE_VERSION VERSION_LESS 3.1
  OR (CMAKE_VERSION VERSION_LESS 3.9 AND CMAKE_CXX_COMPILER_ID MATCHES "^(PGI|XL)$"))
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CXX_FLAGS_CXX11}")
else()
  set(CMAKE_CXX_STANDARD 11)
  set(CMAKE_CXX_STANDARD_REQUIRED ON)
endif()

if(APPLE AND CMAKE_CXX_COMPILER_ID MATCHES "Clang$")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -stdlib=libc++")
endif()

# Set warning-related compiler flags.
if(CMAKE_CXX_COMPILER_ID MATCHES "(Clang|^GNU)$"
  OR (NOT WIN32 AND CMAKE_CXX_COMPILER_ID STREQUAL "Intel"))
  set(CXX_FLAGS_WARNING "-Wreturn-type -Wuninitialized -Wunused-variable")
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
  set(CXX_FLAGS_WARNING "/wd4996")  # Disable sprintf security warning.
else()
  set(CXX_FLAGS_WARNING)
endif()

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CXX_FLAGS_WARNING}")

set(IRIS_DIR ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME})
set(IRIS_INCLUDE_DIR ${CMAKE_INSTALL_INCLUDEDIR})
set(IRIS_LIBRARY_DIR ${CMAKE_INSTALL_LIBDIR})
set(IRIS_PYTHON_DIR
  ${CMAKE_INSTALL_LIBDIR}/python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}/dist-packages)

add_subdirectory(cxx)
add_subdirectory(python)

if(WITH_MATLAB)
  add_subdirectory(matlab)
endif()

install(FILES license.txt DESTINATION ${CMAKE_INSTALL_DOCDIR})
