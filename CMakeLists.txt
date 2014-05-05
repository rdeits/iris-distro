cmake_minimum_required(VERSION 2.6.0)

# pull in the pods macros. See cmake/pods.cmake for documentation
set(POD_NAME irispy)
include(cmake/pods.cmake)

# require python
find_package(PythonInterp REQUIRED)

# install all python files in the python/ subdirectory
pods_install_python_packages(${CMAKE_CURRENT_SOURCE_DIR}/python)

# install a script "hello-python" that runs the hello.main python module
# This script gets installed to ${CMAKE_INSTALL_PREFIX}/bin/hello-python
# and automatically sets the correct python path.
# pods_install_python_script(hello-python hello.main)
