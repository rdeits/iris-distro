# add_library(iris_util iris_util.c)
# target_link_libraries(iris_util lapack)

add_library(iris_mosek iris_mosek.cpp)
target_link_libraries(iris_mosek mosek64)

add_library(iris_core iris.cpp)
target_link_libraries(iris_core iris_mosek iris_util)

# add_executable(testIris iris_test.c)
# target_link_libraries(testIris iris_core)
# add_test(testIris ${CMAKE_BINARY_DIR}/bin/testIris)