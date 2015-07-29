add_library(iris SHARED iris.cpp)
pods_use_pkg_config_packages(iris mosek)
target_link_libraries(iris iris_cvxgen_ldp_cpp cdd)

pods_install_headers(iris.hpp iris_utils.hpp iris_mosek.hpp DESTINATION iris)
pods_install_libraries(iris)

add_executable(irisDemo iris_demo.cpp)
target_link_libraries(irisDemo iris)
add_test(irisDemo ${CMAKE_BINARY_DIR}/bin/irisDemo)

add_subdirectory(test)