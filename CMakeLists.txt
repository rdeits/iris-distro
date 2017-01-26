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
set(iris_dependencies)

if (IRIS_WITH_EIGEN)
	ExternalProject_Add(eigen_project
		URL http://bitbucket.org/eigen/eigen/get/3.2.4.tar.bz2
		CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
		)
	ExternalProject_Get_Property(eigen_project SOURCE_DIR)
  set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${SOURCE_DIR}/cmake)
  message("setting module path to include ${SOURCE_DIR}/cmake")
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
	set(iris_dependencies ${iris_dependencies} cdd_project)
endif()

if (IRIS_WITH_MOSEK)
	ExternalProject_Add(mosek_project
	    GIT_REPOSITORY https://github.com/RobotLocomotion/mosek.git
	    GIT_TAG 21b046d424f98ad150c9eeb2e798b0411bf2fbce
	    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
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

ExternalProject_Add(iris_project
	SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/src
    CMAKE_ARGS
      -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
      -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
      -DCMAKE_PREFIX_PATH=${CMAKE_INSTALL_PREFIX}
      -DCMAKE_MODULE_PATH=${CMAKE_MODULE_PATH}
      -DBUILD_TESTING=${BUILD_TESTING}
      -DMatlab_ROOT_DIR=${Matlab_ROOT_DIR}
      -DSWIG_EXECUTABLE=${SWIG_EXECUTABLE}
    INSTALL_DIR ${CMAKE_INSTALL_PREFIX}
    DEPENDS ${iris_dependencies}
    )
ExternalProject_Add_Step(iris_project forceconfigure
 		COMMAND ${CMAKE_COMMAND} -E echo "Force configure of iris"
 		DEPENDEES update
 		DEPENDERS configure
 		ALWAYS 1)

install(FILES)
