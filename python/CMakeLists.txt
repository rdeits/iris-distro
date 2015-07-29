find_package(PythonInterp REQUIRED)

# add_subdirectory(irispy)
add_custom_target(build_cython ALL
	COMMAND python setup.py build_ext --include-dirs="${CMAKE_INSTALL_PREFIX}/include/eigen3:${CMAKE_BINARY_DIR}/include:${CMAKE_INSTALL_PREFIX}/include" --library-dirs="${CMAKE_BINARY_DIR}/lib:${CMAKE_INSTALL_PREFIX}/lib" --inplace --build-temp "${CMAKE_CURRENT_BINARY_DIR}"
	WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/irispy)

pods_install_python_packages(${CMAKE_CURRENT_SOURCE_DIR}/irispy)

add_test(NAME python_tests
	COMMAND nosetests --nocapture irispy
	WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})