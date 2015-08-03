cmake_minimum_required(VERSION 2.8.0)
include(ExternalProject)

if(APPLE)
  cmake_policy(SET CMP0042 NEW)
endif()

if (IRIS_NO_EXTERNALS)
	message("skipping externals")
	set(iris_dependencies)
else()
	message("adding externals")
	ExternalProject_Add(iris_externals
		SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/externals
	    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
	    INSTALL_DIR ${CMAKE_INSTALL_PREFIX}
	    )
	set(iris_dependencies iris_externals)
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
