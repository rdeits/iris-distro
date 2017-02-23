install(DIRECTORY irispy DESTINATION lib/python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}/dist-packages)

if(BUILD_TESTING)
  add_test(NAME python_tests
  	       COMMAND "${PYTHON_EXECUTABLE}" -m nose --nocapture irispy)
  set_property(TEST python_tests PROPERTY ENVIRONMENT "PYTHONPATH=${CMAKE_INSTALL_PREFIX}/lib/python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}/dist-packages")

  if(PYTHON_VERSION_MAJOR EQUAL 2)
    find_program(JUPYTER_EXECUTABLE NAMES jupyter)

    if(JUPYTER_EXECUTABLE)
      add_test(NAME example_iris_2d
               COMMAND "${JUPYTER_EXECUTABLE}" nbconvert --to notebook --execute iris_2d.ipynb --output iris_2d.ipynb
               WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/examples")
      set_tests_properties(example_iris_2d PROPERTIES ENVIRONMENT "PYTHONPATH=${CMAKE_INSTALL_PREFIX}/lib/python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}/dist-packages")

      add_test(NAME example_polyhedrons
               COMMAND "${JUPYTER_EXECUTABLE}" nbconvert --to notebook --execute polyhedrons.ipynb --output polyhedrons.ipynb
               WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/examples")
      set_tests_properties(example_polyhedrons PROPERTIES ENVIRONMENT "PYTHONPATH=${CMAKE_INSTALL_PREFIX}/lib/python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}/dist-packages")
    else()
      message(WARNING "Could NOT find jupyter. Tests will NOT be run.")
    endif()
  endif()
endif()
