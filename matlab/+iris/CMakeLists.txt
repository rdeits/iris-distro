if(MATLAB_FOUND)
	add_mex(inflate_regionmex inflate_regionmex.cpp)
	target_link_libraries(inflate_regionmex iris)
endif()
