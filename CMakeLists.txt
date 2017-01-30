cmake_minimum_required(VERSION 2.8.0)
include(ExternalProject)

if(APPLE AND POLICY CMP0042)
  cmake_policy(SET CMP0042 NEW)
endif()

option(BUILD_TESTING "Build the testing tree." ON)
option(IRIS_WITH_EIGEN "c++ matrix library. Only disable if you have this already." ON)
option(IRIS_WITH_MOSEK "convex optimization solver; free for academics. Only disable if you have this already." ON)
option(IRIS_WITH_CDD   "tool for converting representations of polytopes. Only disable if you have this already." ON)
option(IRIS_WITH_PYBIND11 "binding generator for python based on c++11. Only disable if you have this already." ON)
option(IRIS_WITH_MATLAB "install pure-MATLAB version of IRIS" OFF)
set(iris_dependencies)

if (IRIS_WITH_EIGEN)
	ExternalProject_Add(eigen_project
		URL http://bitbucket.org/eigen/eigen/get/3.2.4.tar.bz2
		CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
		)
	ExternalProject_Get_Property(eigen_project SOURCE_DIR)
  set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${SOURCE_DIR}/cmake)
	set(iris_dependencies ${iris_dependencies} eigen_project)
endif()
if (IRIS_WITH_CDD)
	set(CDD_PROJECT_SRC_DIR ${CMAKE_CURRENT_BINARY_DIR}/cdd_project-prefix/src/cdd_project)
	ExternalProject_Add(cdd_project
		URL https://s3.amazonaws.com/drake-provisioning/cddlib-094h.tar.gz
		PATCH_COMMAND patch -p1 < ${CMAKE_CURRENT_SOURCE_DIR}/cdd.patch
    CONFIGURE_COMMAND ${CDD_PROJECT_SRC_DIR}/configure --prefix=${CMAKE_INSTALL_PREFIX}
    BUILD_COMMAND make
    BUILD_IN_SOURCE 1
    )
  ExternalProject_Get_Property(cdd_project SOURCE_DIR)
  ExternalProject_Add_Step(cdd_project install_setoper_header
    COMMAND cp ${SOURCE_DIR}/lib-src/setoper.h ${CMAKE_INSTALL_PREFIX}/include
    DEPENDEES install
    COMMENT "installing setoper.h header manually"
  )
	set(iris_dependencies ${iris_dependencies} cdd_project)
endif()

if (IRIS_WITH_MOSEK)
	ExternalProject_Add(mosek_project
	    GIT_REPOSITORY https://github.com/RobotLocomotion/mosek.git
	    GIT_TAG 21b046d424f98ad150c9eeb2e798b0411bf2fbce
	    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
        -DWITH_MATLAB:BOOL=${IRIS_WITH_MATLAB}
	    INSTALL_DIR ${CMAKE_INSTALL_PREFIX}
	    )
	set(iris_dependencies ${iris_dependencies} mosek_project)
endif()

if (IRIS_WITH_PYBIND11)
  ExternalProject_Add(pybind11_project
    GIT_REPOSITORY https://github.com/pybind/pybind11.git
    GIT_TAG 7830e8509f2adc97ce9ee32bf99cd4b82089cc4c
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} -DPYBIND11_TEST=OFF
    )
  set(iris_dependencies ${iris_dependencies} pybind11_project)
endif()

list(INSERT CMAKE_PREFIX_PATH 0 "${CMAKE_INSTALL_PREFIX}")

set(IRIS_CMAKE_ARGS 
      -DBUILD_TESTING=${BUILD_TESTING}
      -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
      -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
      -DCMAKE_MODULE_PATH=${CMAKE_MODULE_PATH}
      -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
      -DWITH_MATLAB=${IRIS_WITH_MATLAB}
      -DPYBIND11_PYTHON_VERSION=${PYBIND11_PYTHON_VERSION})

if (DEFINED PYTHON_EXECUTABLE)
  set(IRIS_CMAKE_ARGS ${IRIS_CMAKE_ARGS} -DPYTHON_EXECUTABLE=${PYTHON_EXECUTABLE})
endif()
if (DEFINED PYTHON_INCLUDE_DIR)
  set(IRIS_CMAKE_ARGS ${IRIS_CMAKE_ARGS} -DPYTHON_INCLUDE_DIR=${PYTHON_INCLUDE_DIR})
endif()
if (DEFINED PYTHON_LIBRARY)
  set(IRIS_CMAKE_ARGS ${IRIS_CMAKE_ARGS} -DPYTHON_LIBRARY=${PYTHON_LIBRARY})
endif()

ExternalProject_Add(iris_project
	SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/src
    CMAKE_ARGS ${IRIS_CMAKE_ARGS}
    INSTALL_DIR ${CMAKE_INSTALL_PREFIX}
    DEPENDS ${iris_dependencies}
    )
ExternalProject_Add_Step(iris_project forceconfigure
 		COMMAND ${CMAKE_COMMAND} -E echo "Force configure of iris"
 		DEPENDEES update
 		DEPENDERS configure
 		ALWAYS 1)

install(FILES)
