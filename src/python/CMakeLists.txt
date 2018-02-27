install(DIRECTORY irispy DESTINATION ${IRIS_PYTHON_DIR})

if(BUILD_TESTING)
  add_test(NAME python_tests
    COMMAND "${PYTHON_EXECUTABLE}" -m nose --nocapture irispy)
  set_property(TEST python_tests PROPERTY ENVIRONMENT "PYTHONPATH=${CMAKE_INSTALL_PREFIX}/${IRIS_PYTHON_DIR}")

  if(PYTHON_VERSION_MAJOR EQUAL 2)
    find_program(JUPYTER_EXECUTABLE NAMES jupyter)

    if(JUPYTER_EXECUTABLE)
      add_test(NAME example_iris_2d
        COMMAND "${JUPYTER_EXECUTABLE}" nbconvert --to notebook --execute iris_2d.ipynb --output iris_2d.ipynb
        WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/examples")
      set_tests_properties(example_iris_2d PROPERTIES ENVIRONMENT "PYTHONPATH=${CMAKE_INSTALL_PREFIX}/${IRIS_PYTHON_DIR}")

      add_test(NAME example_polyhedrons
        COMMAND "${JUPYTER_EXECUTABLE}" nbconvert --to notebook --execute polyhedrons.ipynb --output polyhedrons.ipynb
        WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/examples")
      set_tests_properties(example_polyhedrons PROPERTIES ENVIRONMENT "PYTHONPATH=${CMAKE_INSTALL_PREFIX}/${IRIS_PYTHON_DIR}")
    endif()
  endif()
endif()
