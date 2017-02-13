add_subdirectory(cvxgen)

add_library(iris_geometry SHARED geometry.cpp
  iris/geometry.h iris_cdd.h)
set_target_properties(iris_geometry PROPERTIES PUBLIC_HEADER iris/geometry.h)
target_include_directories(iris_geometry PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}> "${EIGEN3_INCLUDE_DIR}")
target_include_directories(iris_geometry PRIVATE "${CDD_INCLUDE_DIR}")
target_link_libraries(iris_geometry "${CDD_LIBRARY}")

add_library(iris_mosek SHARED iris_mosek.cpp
  iris/iris_mosek.h)
set_target_properties(iris_mosek PROPERTIES PUBLIC_HEADER iris/iris_mosek.h)
target_include_directories(iris_mosek PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>)
target_link_libraries(iris_mosek iris_geometry mosek)

add_library(iris SHARED iris.cpp IRISProblem.cpp)
set_target_properties(iris PROPERTIES PUBLIC_HEADER iris/iris.h)
target_include_directories(iris PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}> "${EIGEN3_INCLUDE_DIR}")
target_link_libraries(iris iris_cvxgen_ldp_cpp iris_geometry iris_mosek)

install(TARGETS iris iris_geometry iris_mosek
  INCLUDES DESTINATION ${IRIS_INCLUDE_DIR}
  LIBRARY DESTINATION ${IRIS_LIBRARY_DIR}
  PUBLIC_HEADER DESTINATION ${IRIS_INCLUDE_DIR}/iris
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})

if(BUILD_TESTING)
  add_executable(irisDemo iris_demo.cpp)
  target_link_libraries(irisDemo iris)
  add_test(NAME irisDemo COMMAND irisDemo)

  add_subdirectory(test)
endif()

pybind11_add_module(iris_wrapper iris_wrapper.cpp)
target_include_directories(iris_wrapper PRIVATE "${NUMPY_INCLUDE_DIRS}")
target_link_libraries(iris_wrapper PRIVATE iris iris_geometry iris_cvxgen_ldp iris_cvxgen_ldp_cpp)
install(TARGETS iris_wrapper
  LIBRARY DESTINATION ${IRIS_PYTHON_DIR}/irispy
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
