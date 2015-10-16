find_package(NumPy REQUIRED)
include_directories(${NUMPY_INCLUDE_DIRS})

execute_process(COMMAND python-config --prefix
	OUTPUT_VARIABLE PYTHON_PREFIX
	OUTPUT_STRIP_TRAILING_WHITESPACE
	)
# Overload the PYTHON_INCLUDE_DIR because, on OSX, cmake finds the correct library version but latches on to an old Apple-provided python 2.6 header directory. 
set(PYTHON_INCLUDE_DIR ${PYTHON_PREFIX}/include/python${PYVERSION})

find_package(Cython)
if (CYTHON_FOUND)
	include(UseCython)

	set_source_files_properties(
		${CMAKE_CURRENT_SOURCE_DIR}/iriscore.pyx
		${CMAKE_CURRENT_SOURCE_DIR}/iriscoretest.pyx
		PROPERTIES CYTHON_IS_CXX TRUE )

	cython_add_module(iriscore iriscore.pyx)
	target_link_libraries(iriscore iris)
	cython_add_module(iriscoretest iriscoretest.pyx)
	target_link_libraries(iriscoretest iris)
else()
	find_package( PythonLibs REQUIRED )
	include_directories( ${PYTHON_INCLUDE_DIRS} )

	python_add_module( iriscore ${CMAKE_CURRENT_SOURCE_DIR}/iriscore.cpp )
	python_add_module( iriscoretest ${CMAKE_CURRENT_SOURCE_DIR}/iriscoretest.cpp )
	if( APPLE )
		set_target_properties( iriscore PROPERTIES LINK_FLAGS "-undefined dynamic_lookup" )
		set_target_properties( iriscoretest PROPERTIES LINK_FLAGS "-undefined dynamic_lookup" )
	else()
		target_link_libraries( iriscore ${PYTHON_LIBRARIES} )
		target_link_libraries( iriscoretest ${PYTHON_LIBRARIES} )
	endif()
	target_link_libraries(iriscore iris)
	target_link_libraries(iriscoretest iris)
endif()

install(TARGETS iriscore iriscoretest
	    DESTINATION lib/python${PYVERSION}/dist-packages/irispy)
