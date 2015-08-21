include(SwigPython)

find_package(PythonInterp REQUIRED)
set(python_install_dir lib/python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}/dist-packages)

add_swig_python_module(TARGET iris_wrapper
                       SWIG_I_FILE ${CMAKE_CURRENT_SOURCE_DIR}/iris_wrapper.i
                       CPLUSPLUS
                       INCLUDE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}/../src
                       LINK_LIBRARIES iris
                       SWIG_INCLUDE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}/../swigmake/swig
                       DESTINATION ${python_install_dir}/irispy)
pods_install_python_packages(${CMAKE_CURRENT_SOURCE_DIR})
