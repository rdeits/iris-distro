add_library(iris iris.cpp)
target_link_libraries(iris mosek64 iris_cvxgen_ldp_cpp cdd)

add_executable(testIris test_iris.cpp)
target_link_libraries(testIris iris)
add_test(testIris ${CMAKE_BINARY_DIR}/bin/testIris)
pods_install_executables(testIris)

pods_install_headers(iris.hpp iris_utils.hpp DESTINATION iris)
# pods_install_libraries(iris iris_mosek iris_classes)
pods_install_libraries(iris)

# add_executable(testPPL test_ppl.cpp)
# target_link_libraries(testPPL ppl gmp iris)
# pods_install_executables(testPPL)

add_executable(testCDD test_cdd.cpp)
target_link_libraries(testCDD iris)
pods_install_executables(testCDD)