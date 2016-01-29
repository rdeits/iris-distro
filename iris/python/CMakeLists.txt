include(SwigPython)

find_package(PythonInterp REQUIRED)
set(python_install_dir lib/python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}/dist-packages)

add_swig_python_module(irisWrapperPython iris_wrapper.i
                       CPLUSPLUS
                       SWIG_INCLUDE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}/../swigmake/swig/python
                       INCLUDE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}/../src
                       LINK_LIBRARIES iris
                       DESTINATION ${python_install_dir}/irispy ${CMAKE_CURRENT_SOURCE_DIR}/irispy)

pods_install_python_packages(${CMAKE_CURRENT_SOURCE_DIR})

add_test(NAME python_tests
	COMMAND nosetests --nocapture irispy 
	WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})