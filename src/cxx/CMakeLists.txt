add_subdirectory(cvxgen)

add_library(iris_geometry SHARED geometry.cpp
  iris/geometry.h iris_cdd.h)
set_target_properties(iris_geometry PROPERTIES
  PUBLIC_HEADER iris/geometry.h
  SOVERSION 0)
target_include_directories(iris_geometry PRIVATE "${CDD_INCLUDE_DIR}"
  PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>)
if(TARGET Eigen3::Eigen)
  target_link_libraries(iris_geometry Eigen3::Eigen)
else()
  target_include_directories(iris_geometry PUBLIC "${EIGEN3_INCLUDE_DIR}")
endif()
target_link_libraries(iris_geometry "${CDD_LIBRARY}")

add_library(iris_mosek SHARED iris_mosek.cpp
  iris/iris_mosek.h)
set_target_properties(iris_mosek PROPERTIES
  PUBLIC_HEADER iris/iris_mosek.h
  SOVERSION 0)
target_include_directories(iris_mosek
  PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>)
target_link_libraries(iris_mosek iris_geometry mosek)

add_library(iris SHARED iris.cpp IRISProblem.cpp)
set_target_properties(iris PROPERTIES
  PUBLIC_HEADER iris/iris.h
  SOVERSION 0)
target_include_directories(iris
  PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>)
if(TARGET Eigen3::Eigen)
  target_link_libraries(iris Eigen3::Eigen)
else()
  target_include_directories(iris PUBLIC "${EIGEN3_INCLUDE_DIR}")
endif()
target_link_libraries(iris iris_cvxgen_ldp_cpp iris_geometry iris_mosek)

export(TARGETS iris iris_geometry iris_mosek NAMESPACE iris::
  APPEND FILE iris-targets.cmake)

install(TARGETS iris iris_geometry iris_mosek
  EXPORT iris-targets
  INCLUDES DESTINATION ${IRIS_INCLUDE_DIR}
  LIBRARY DESTINATION ${IRIS_LIBRARY_DIR}
  PUBLIC_HEADER DESTINATION ${IRIS_INCLUDE_DIR}/iris
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})

configure_file(iris.pc.in iris.pc @ONLY)

install(FILES "${CMAKE_CURRENT_BINARY_DIR}/iris.pc"
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig)

# If we are using the Eigen3::Eigen imported target, the iris package
# configuration file needs a find_dependency call so that the imported target
# is defined in dependent projects.
if(TARGET Eigen3::Eigen)
  set(FIND_DEPENDENCY_EIGEN3 "find_dependency(Eigen3)")
else()
  set(FIND_DEPENDENCY_EIGEN3)
endif()

configure_package_config_file(iris-config.cmake.in iris-config.cmake
  INSTALL_DESTINATION ${IRIS_DIR}
  PATH_VARS IRIS_INCLUDE_DIR IRIS_LIBRARY_DIR
  NO_CHECK_REQUIRED_COMPONENTS_MACRO)

install(EXPORT iris-targets NAMESPACE iris:: DESTINATION ${IRIS_DIR})

install(FILES "${CMAKE_CURRENT_BINARY_DIR}/iris-config.cmake"
  DESTINATION ${IRIS_DIR})

if(BUILD_TESTING)
  add_executable(irisDemo iris_demo.cpp)
  target_link_libraries(irisDemo iris)
  add_test(NAME irisDemo COMMAND irisDemo)

  add_subdirectory(test)
endif()

pybind11_add_module(iris_wrapper iris_wrapper.cpp)
target_include_directories(iris_wrapper PRIVATE "${NUMPY_INCLUDE_DIRS}")
target_link_libraries(iris_wrapper
  PRIVATE iris iris_geometry iris_cvxgen_ldp iris_cvxgen_ldp_cpp)

install(TARGETS iris_wrapper
  LIBRARY DESTINATION ${IRIS_PYTHON_DIR}/irispy
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
