add_subdirectory(cvxgen)

add_library(iris_geometry SHARED geometry.cpp)
set_target_properties(iris_geometry PROPERTIES PUBLIC_HEADER "geometry.h")
target_link_libraries(iris_geometry cdd)

add_library(iris_mosek SHARED iris_mosek.cpp)
set_target_properties(iris_mosek PROPERTIES PUBLIC_HEADER "iris_mosek.h")
target_link_libraries(iris_geometry cdd)
target_link_libraries(iris_mosek mosek)
target_link_libraries(iris_mosek iris_geometry)

add_library(iris SHARED iris.cpp IRISProblem.cpp)
set_target_properties(iris PROPERTIES PUBLIC_HEADER "iris.h")
target_link_libraries(iris iris_cvxgen_ldp_cpp iris_mosek)

install(TARGETS iris iris_geometry iris_mosek
  LIBRARY DESTINATION lib
  PUBLIC_HEADER DESTINATION include/iris)

# pods_install_headers(iris.h iris_mosek.h geometry.h DESTINATION iris)
# pods_install_libraries(iris iris_geometry iris_mosek)

# if(BUILD_TESTING)
#   add_executable(irisDemo iris_demo.cpp)
#   target_link_libraries(irisDemo iris)
#   add_test(irisDemo ${CMAKE_BINARY_DIR}/bin/irisDemo)

#   add_subdirectory(test)
# endif()


pybind11_add_module(iris_wrapper iris_wrapper.cpp)
target_link_libraries(iris_wrapper PRIVATE iris iris_geometry iris_cvxgen_ldp iris_cvxgen_ldp_cpp)
install(TARGETS iris_wrapper DESTINATION lib/python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}/dist-packages/irispy)

