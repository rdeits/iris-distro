cmake_minimum_required(VERSION 2.8.0)
include(ExternalProject)

if(APPLE)
  cmake_policy(SET CMP0042 NEW)
endif()

option(WITH_EIGEN "c++ matrix library. Only disable if you have this already." ON)
option(WITH_MOSEK "convex optimization solver; free for academics. Only disable if you have this already." ON)
option(WITH_CDD   "tool for converting representations of polytopes. Only disable if you have this already." ON)
set(iris_dependencies)

if (WITH_EIGEN)
	ExternalProject_Add(eigen_project
		URL http://bitbucket.org/eigen/eigen/get/3.2.4.tar.bz2
		CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
		)
	ExternalProject_Get_Property(eigen_project BINARY_DIR)
	ExternalProject_Add_Step(eigen_project install_pc_file
		COMMAND mkdir -p ${CMAKE_INSTALL_PREFIX}/lib/pkgconfig && cp ${BINARY_DIR}/eigen3.pc ${CMAKE_INSTALL_PREFIX}/lib/pkgconfig/eigen3.pc
		DEPENDEES install
		COMMENT "installing eigen3.pc file for pkg-config"
		)
	set(iris_dependencies ${iris_dependencies} eigen_project)
endif()
if (WITH_CDD)
	set(CDD_PROJECT_SRC_DIR ${CMAKE_CURRENT_BINARY_DIR}/cdd_project-prefix/src/cdd_project)
	ExternalProject_Add(cdd_project
		URL ftp://ftp.ifor.math.ethz.ch/pub/fukuda/cdd/cddlib-094h.tar.gz
	    CONFIGURE_COMMAND ${CDD_PROJECT_SRC_DIR}/configure --prefix=${CMAKE_INSTALL_PREFIX}
	    BUILD_COMMAND make
	    BUILD_IN_SOURCE 1
	    )
	set(iris_dependencies ${iris_dependencies} cdd_project)
endif()

if (WITH_MOSEK)
	ExternalProject_Add(mosek_project
	    GIT_REPOSITORY https://github.com/RobotLocomotion/mosek.git
	    GIT_TAG a72594c4a7c8c5c026fd291148bcac76146634c2
	    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
	    INSTALL_DIR ${CMAKE_INSTALL_PREFIX}
	    )
	set(iris_dependencies ${iris_dependencies} mosek_project)
endif()

ExternalProject_Add(iris_project
	SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/iris
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
    INSTALL_DIR ${CMAKE_INSTALL_PREFIX}
    DEPENDS ${iris_dependencies}
    )
ExternalProject_Add_Step(iris_project forceconfigure
 		COMMAND ${CMAKE_COMMAND} -E echo "Force configure of iris"
 		DEPENDEES update
 		DEPENDERS configure
 		ALWAYS 1)
