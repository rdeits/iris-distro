find_package(PythonInterp REQUIRED)
execute_process(COMMAND
    ${PYTHON_EXECUTABLE} -c "import sys; sys.stdout.write(sys.version[:3])"
    OUTPUT_VARIABLE PYVERSION)

execute_process(COMMAND python-config --prefix
	OUTPUT_VARIABLE PYTHON_PREFIX
	OUTPUT_STRIP_TRAILING_WHITESPACE
	)
# Overload the PYTHON_INCLUDE_DIR because, on OSX, cmake finds the correct library version but latches on to an old Apple-provided python 2.6 header directory. 
set(PYTHON_INCLUDE_DIR ${PYTHON_PREFIX}/include/python${PYVERSION})
if(APPLE)
	set(PYTHON_LIBRARY ${PYTHON_PREFIX}/lib/libpython${PYVERSION}.dylib)
endif()

find_package(SWIG)
include(UseSWIG)

find_package(NumPy REQUIRED)
include_directories(${NUMPY_INCLUDE_DIRS})

find_package( PythonLibs REQUIRED )
include_directories( ${PYTHON_INCLUDE_DIRS} )
include_directories( ${CMAKE_CURRENT_SOURCE_DIR}/../src )
message("PYTHON_INCLUDE_DIRS" ${PYTHON_INCLUDE_DIRS})
message("PYTHON_LIBRARIES" ${PYTHON_LIBRARIES})

set(CMAKE_SWIG_OUTDIR ${CMAKE_CURRENT_SOURCE_DIR})
set_source_files_properties(iris_wrapper.i PROPERTIES CPLUSPLUS ON)
swig_add_module(iris_wrapper python ${CMAKE_CURRENT_SOURCE_DIR}/iris_wrapper.i)
swig_link_libraries(iris_wrapper iris ${PYTHON_LIBRARIES})
message("real name: " ${SWIG_MODULE_irispy_swig_REAL_NAME})
install(TARGETS ${SWIG_MODULE_iris_wrapper_REAL_NAME} DESTINATION ${CMAKE_CURRENT_SOURCE_DIR})
