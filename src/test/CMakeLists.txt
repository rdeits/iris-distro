add_executable(testCDD test_cdd.cpp)
target_link_libraries(testCDD iris)
add_test(testCDD ${CMAKE_BINARY_DIR}/bin/testCDD)

add_executable(testIris test_iris.cpp)
target_link_libraries(testIris iris)
add_test(testIris ${CMAKE_BINARY_DIR}/bin/testIris)

