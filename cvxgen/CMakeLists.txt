add_library(cvxgen_ldp SHARED solver.c matrix_support.c ldl.c util.c cvxgen_ldp.c)

if(WIN32 AND NOT CYGWIN)
  set_target_properties(cvxgen_ldp PROPERTIES SUFFIX ".pyd")
else()
  set_target_properties(cvxgen_ldp PROPERTIES PREFIX "" SUFFIX ".so")
endif()

install(TARGETS cvxgen_ldp DESTINATION lib/python2.7/dist-packages/irispy)

set(mex_suffix mexa64)
if(APPLE)
  set(mex_suffix mexmaci64)
endif()

add_library(iris_ldp SHARED solver.c matrix_support.c ldl.c util.c)
pods_install_libraries(iris_ldp)
pods_install_headers(solver.h DESTINATION iris_ldp)

add_custom_command(OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/cvxgen_ldp_mex.${mex_suffix}
  COMMAND matlab -nodisplay -r \"make_csolve\; quit\(\)\;\"
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})

add_custom_target(cvxgen_mex ALL DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/cvxgen_ldp_mex.${mex_suffix})

install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/cvxgen_ldp_mex.${mex_suffix} DESTINATION ${CMAKE_CURRENT_SOURCE_DIR}/../matlab)
