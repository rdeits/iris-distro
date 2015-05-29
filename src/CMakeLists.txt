add_library(irisCore iris.c)
target_link_libraries(irisCore m mosek64)
add_executable(iris iris.c)
target_link_libraries(iris m mosek64)