cmake_minimum_required(VERSION 2.8)
include(ExternalProject)

ExternalProject_Add(eigen_project
	URL http://bitbucket.org/eigen/eigen/get/3.2.4.tar.bz2
	CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
	INSTALL_DIR ${CMAKE_INSTALL_PREFIX}
	)
ExternalProject_Get_Property(eigen_project BINARY_DIR)
install(FILES ${BINARY_DIR}/eigen3.pc DESTINATION lib/pkgconfig)

set(CDD_PROJECT_SRC_DIR ${CMAKE_CURRENT_BINARY_DIR}/cdd_project-prefix/src/cdd_project)
ExternalProject_Add(cdd_project
    GIT_REPOSITORY https://github.com/mcmtroffaes/cddlib.git
    GIT_TAG 370919d5169e9927de90d19e56f28dc6a9bfa59a
    UPDATE_COMMAND ""
    CONFIGURE_COMMAND ${CDD_PROJECT_SRC_DIR}/bootstrap.sh && ${CDD_PROJECT_SRC_DIR}/configure --prefix=${CMAKE_INSTALL_PREFIX}
    BUILD_COMMAND make
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make install
    )