cmake_minimum_required(VERSION 2.8.0)

project(swigmake)

foreach (folder common matlab python)
	file(GLOB files ${CMAKE_CURRENT_SOURCE_DIR}/swig/${folder}/*.i)
	install(FILES ${files} DESTINATION share/swig/${folder})
endforeach(folder)

file(GLOB files ${CMAKE_CURRENT_SOURCE_DIR}/cmake/*.cmake)
install(FILES ${files} DESTINATION share/cmake)
