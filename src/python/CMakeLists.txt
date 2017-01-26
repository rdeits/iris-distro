install(DIRECTORY irispy DESTINATION lib/python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}/dist-packages)

if(BUILD_TESTING)
  add_test(NAME python_tests
  	       COMMAND "python${PYTHON_VERSION_MAJOR}" -m nose --nocapture irispy)
  set_property(TEST python_tests PROPERTY ENVIRONMENT "PYTHONPATH=${CMAKE_INSTALL_PREFIX}/lib/python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}/dist-packages")

  if (PYTHON_VERSION_MAJOR EQUAL 2)
    add_test(NAME example_iris_2d
  	       COMMAND jupyter nbconvert --to notebook --execute iris_2d.ipynb --output iris_2d.ipynb
  	       WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/examples)
    set_property(TEST example_iris_2d PROPERTY ENVIRONMENT "PYTHONPATH=${CMAKE_INSTALL_PREFIX}/lib/python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}/dist-packages")


    add_test(NAME example_polyhedrons
             COMMAND jupyter nbconvert --to notebook --execute polyhedrons.ipynb --output polyhedrons.ipynb
             WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/examples)
    set_property(TEST example_polyhedrons PROPERTY ENVIRONMENT "PYTHONPATH=${CMAKE_INSTALL_PREFIX}/lib/python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}/dist-packages")
  endif()
endif()

