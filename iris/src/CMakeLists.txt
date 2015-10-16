add_library(iris_geometry SHARED geometry.cpp)
target_link_libraries(iris_geometry cdd)

add_library(iris_mosek SHARED iris_mosek.cpp)
pods_use_pkg_config_packages(iris_mosek mosek)
target_link_libraries(iris_mosek iris_geometry)

add_library(iris SHARED iris.cpp IRISProblem.cpp)
pods_use_pkg_config_packages(iris mosek)
target_link_libraries(iris iris_cvxgen_ldp_cpp iris_mosek)

pods_install_headers(iris.h iris_mosek.h geometry.h DESTINATION iris)
pods_install_libraries(iris iris_geometry iris_mosek)

add_executable(irisDemo iris_demo.cpp)
target_link_libraries(irisDemo iris)
add_test(irisDemo ${CMAKE_BINARY_DIR}/bin/irisDemo)

add_subdirectory(test)