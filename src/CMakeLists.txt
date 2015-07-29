add_library(iris SHARED iris.cpp)
pods_use_pkg_config_packages(iris mosek)
target_link_libraries(iris iris_cvxgen_ldp_cpp cdd)

add_executable(testIris test_iris.cpp)
target_link_libraries(testIris iris)
add_test(testIris ${CMAKE_BINARY_DIR}/bin/testIris)
pods_install_executables(testIris)

add_executable(irisDemo iris_demo.cpp)
target_link_libraries(irisDemo iris)
add_test(irisDemo ${CMAKE_BINARY_DIR}/bin/irisDemo)

pods_install_headers(iris.hpp iris_utils.hpp DESTINATION iris)
pods_install_libraries(iris)

add_executable(testCDD test_cdd.cpp)
target_link_libraries(testCDD iris)
pods_install_executables(testCDD)