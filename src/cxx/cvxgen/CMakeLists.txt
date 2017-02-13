add_library(iris_cvxgen_ldp SHARED solver.c matrix_support.c ldl.c util.c cvxgen_ldp.c
  iris/cvxgen_ldp.h solver.h)
set_target_properties(iris_cvxgen_ldp PROPERTIES PUBLIC_HEADER iris/cvxgen_ldp.h)
target_include_directories(iris_cvxgen_ldp PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>)

add_library(iris_cvxgen_ldp_cpp SHARED cvxgen_ldp.cpp)
target_link_libraries(iris_cvxgen_ldp_cpp iris_cvxgen_ldp)

install(TARGETS iris_cvxgen_ldp iris_cvxgen_ldp_cpp
  LIBRARY DESTINATION lib
  PUBLIC_HEADER DESTINATION include/iris)
