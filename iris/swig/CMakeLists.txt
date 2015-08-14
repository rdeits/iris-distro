find_package(NumPy REQUIRED)
include_directories(${NUMPY_INCLUDE_DIRS})

execute_process(COMMAND
    ${PYTHON_EXECUTABLE} -c "import sys; sys.stdout.write(sys.version[:3])"
    OUTPUT_VARIABLE PYVERSION)

execute_process(COMMAND python-config --prefix
	OUTPUT_VARIABLE PYTHON_PREFIX
	OUTPUT_STRIP_TRAILING_WHITESPACE
	)
# Overload the PYTHON_INCLUDE_DIR because, on OSX, cmake finds the correct library version but latches on to an old Apple-provided python 2.6 header directory. 
set(PYTHON_INCLUDE_DIR ${PYTHON_PREFIX}/include/python${PYVERSION})

find_package(SWIG)
include(UseSWIG)

find_package( PythonLibs REQUIRED )
include_directories( ${PYTHON_INCLUDE_DIRS} )
include_directories( ${CMAKE_CURRENT_SOURCE_DIR}/../src )
message("PYTHON_INCLUDE_DIRS" ${PYTHON_INCLUDE_DIRS})

set(CMAKE_SWIG_OUTDIR ${CMAKE_CURRENT_SOURCE_DIR})
set_source_files_properties(irispy_swig.i PROPERTIES CPLUSPLUS ON)
swig_add_module(irispy_swig python ${CMAKE_CURRENT_SOURCE_DIR}/irispy_swig.i)
swig_link_libraries(irispy_swig iris)
message("real name: " ${SWIG_MODULE_irispy_swig_REAL_NAME})
install(TARGETS ${SWIG_MODULE_irispy_swig_REAL_NAME} DESTINATION ${CMAKE_CURRENT_SOURCE_DIR})

# add_custom_command(OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/irispy_wrap.cxx
#                    COMMAND swig -c++ -python -I

# python_add_module( _irispycore ${CMAKE_CURRENT_SOURCE_DIR}/irispy_wrap.cxx )
# if( APPLE )
# 	set_target_properties( _irispycore PROPERTIES LINK_FLAGS "-undefined dynamic_lookup" )
# else()
# 	target_link_libraries( _irispycore ${PYTHON_LIBRARIES} )
# endif()
# target_link_libraries(_irispycore iris)
