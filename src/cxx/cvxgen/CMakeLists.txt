add_library(iris_cvxgen_ldp SHARED solver.c matrix_support.c ldl.c util.c cvxgen_ldp.c
  iris/cvxgen_ldp.h solver.h)
target_include_directories(iris_cvxgen_ldp
  PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>)
set_target_properties(iris_cvxgen_ldp PROPERTIES PUBLIC_HEADER iris/cvxgen_ldp.h)

add_library(iris_cvxgen_ldp_cpp SHARED cvxgen_ldp.cpp)
target_include_directories(iris_cvxgen_ldp_cpp PUBLIC "${EIGEN3_INCLUDE_DIR}")
target_link_libraries(iris_cvxgen_ldp_cpp iris_cvxgen_ldp)

install(TARGETS iris_cvxgen_ldp iris_cvxgen_ldp_cpp
  LIBRARY DESTINATION ${IRIS_LIBRARY_DIR}
  PUBLIC_HEADER DESTINATION ${IRIS_INCLUDE_DIR}/iris
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
