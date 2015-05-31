add_library(iris_mosek iris_mosek.c)
target_link_libraries(iris_mosek m mosek64)

add_library(iris_core iris.c)
target_link_libraries(iris_core iris_mosek lapack)

add_executable(testIris iris_test.c)
target_link_libraries(testIris iris_core)