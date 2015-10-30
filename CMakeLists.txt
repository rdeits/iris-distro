cmake_minimum_required(VERSION 2.8.0)

project(swigmake)

install(DIRECTORY swig/ DESTINATION share/swig)
install(DIRECTORY cmake/ DESTINATION share/cmake)
