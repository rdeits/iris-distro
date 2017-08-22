add_library(iris_cvxgen_ldp SHARED solver.c matrix_support.c ldl.c util.c cvxgen_ldp.c
  iris/cvxgen_ldp.h solver.h)
target_include_directories(iris_cvxgen_ldp
  PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>)
set_target_properties(iris_cvxgen_ldp PROPERTIES
  PUBLIC_HEADER iris/cvxgen_ldp.h
  SOVERSION 0)

add_library(iris_cvxgen_ldp_cpp SHARED cvxgen_ldp.cpp)
if(TARGET Eigen3::Eigen)
  target_link_libraries(iris_cvxgen_ldp_cpp Eigen3::Eigen)
else()
  target_include_directories(iris_cvxgen_ldp_cpp PUBLIC "${EIGEN3_INCLUDE_DIR}")
endif()
target_link_libraries(iris_cvxgen_ldp_cpp iris_cvxgen_ldp)
set_target_properties(iris_cvxgen_ldp_cpp PROPERTIES SOVERSION 0)

export(TARGETS iris_cvxgen_ldp iris_cvxgen_ldp_cpp NAMESPACE iris::
  APPEND FILE iris-targets.cmake)

install(TARGETS iris_cvxgen_ldp iris_cvxgen_ldp_cpp
  EXPORT iris-targets
  LIBRARY DESTINATION ${IRIS_LIBRARY_DIR}
  PUBLIC_HEADER DESTINATION ${IRIS_INCLUDE_DIR}/iris
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
