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

# setup matlab pods-compliance
include(cmake/matlab_pods.cmake)
pods_configure_matlab_paths()

get_relative_path("${CMAKE_INSTALL_PREFIX}/matlab" "${CMAKE_CURRENT_SOURCE_DIR}/matlab" relpath)

message(STATUS "Writing addpath_iris.m and rmpath_iris.m to ${CMAKE_INSTALL_PREFIX}/matlab")
file(WRITE ${CMAKE_INSTALL_PREFIX}/matlab/addpath_iris.m
	   "function addpath_iris()\n"
	   "  mfiledir = fileparts(which(mfilename));\n"
	   "  wd = cd(fullfile(mfiledir,'${relpath}'));\n"
	   "  addpath_iris();\n"
	   "  cd(wd);\n"
    )

file(WRITE ${CMAKE_INSTALL_PREFIX}/matlab/rmpath_iris.m
	   "function rmpath_iris()\n"
	   "  mfiledir = fileparts(which(mfilename));\n"
	   "  wd = cd(fullfile(mfiledir,'${relpath}'));\n"
	   "  rmpath_iris();\n"
	   "  cd(wd);\n"
    )

add_subdirectory(cvxgen)