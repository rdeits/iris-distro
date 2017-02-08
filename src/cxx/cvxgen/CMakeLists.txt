add_library(iris_cvxgen_ldp SHARED solver.c matrix_support.c ldl.c util.c cvxgen_ldp.c)
# pods_install_headers(cvxgen_ldp.h DESTINATION iris)

add_library(iris_cvxgen_ldp_cpp SHARED cvxgen_ldp.cpp)
target_link_libraries(iris_cvxgen_ldp_cpp iris_cvxgen_ldp)

install(TARGETS iris_cvxgen_ldp_cpp iris_cvxgen_ldp
        LIBRARY DESTINATION lib)

install(FILES cvxgen_ldp.h DESTINATION include/iris)
