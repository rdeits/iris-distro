cmake_minimum_required(VERSION 2.8.0)
include(ExternalProject)

if(APPLE AND POLICY CMP0042)
  cmake_policy(SET CMP0042 NEW)
endif()

option(BUILD_TESTING "Build the testing tree." ON)
option(IRIS_WITH_EIGEN "c++ matrix library. Only disable if you have this already." ON)
option(IRIS_WITH_MOSEK "convex optimization solver; free for academics. Only disable if you have this already." ON)
option(IRIS_WITH_CDD   "tool for converting representations of polytopes. Only disable if you have this already." ON)
set(iris_dependencies)

message("with eigen: " ${IRIS_WITH_EIGEN})
message("with cdd: " ${IRIS_WITH_CDD})
message("with mosek: " ${IRIS_WITH_MOSEK})

if (IRIS_WITH_EIGEN)
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
	    GIT_TAG 8e93c8ad6e8de0c1401b8e39d187370a3a0bd2dc
	    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
	    INSTALL_DIR ${CMAKE_INSTALL_PREFIX}
	    )
	set(iris_dependencies ${iris_dependencies} mosek_project)
endif()

ExternalProject_Add(iris_project
	SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/iris
    CMAKE_ARGS
      -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
      -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
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
