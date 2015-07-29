# find_package(PythonLibs REQUIRED)
# find_package(PythonInterp REQUIRED)

# add_custom_command(OUTPUT iriscore.cpp
#   COMMAND cython --cplus ${CMAKE_CURRENT_SOURCE_DIR}/iriscore.pyx 
#   DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/iriscore.pyx ${CMAKE_CURRENT_SOURCE_DIR}/iriscore.pxd iris
#   WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})

# # Find the numpy include path
# execute_process(COMMAND ${PYTHON_EXECUTABLE} -c "import numpy; print numpy.get_include()" OUTPUT_VARIABLE NUMPY_INCLUDE_PATH OUTPUT_STRIP_TRAILING_WHITESPACE)

# include_directories(${PYTHON_INCLUDE_DIRS})
# include_directories(${NUMPY_INCLUDE_PATH})
# add_library(iriscore MODULE ${CMAKE_CURRENT_SOURCE_DIR}/iriscore.cpp)
# target_link_libraries(iriscore ${PYTHON_LIBRARIES} iris)
# set_target_properties(iriscore PROPERTIES 
# 	PREFIX ""
# 	OUTPUT_NAME "iriscore"
# 	LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
# install(TARGETS iriscore DESTINATION ${CMAKE_CURRENT_SOURCE_DIR})

