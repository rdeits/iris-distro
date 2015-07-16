add_library(iris iris.cpp iris_classes.cpp iris_mosek.cpp)
target_link_libraries(iris mosek64 iris_cvxgen_ldp_cpp)

add_executable(testIris iris_test.cpp)
target_link_libraries(testIris iris)
add_test(testIris ${CMAKE_BINARY_DIR}/bin/testIris)

pods_install_headers(iris.hpp iris_utils.hpp DESTINATION iris)
# pods_install_libraries(iris iris_mosek iris_classes)
pods_install_libraries(iris)

pods_install_executables(testIris)