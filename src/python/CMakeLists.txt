install(DIRECTORY irispy DESTINATION lib/python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}/dist-packages)

if(BUILD_TESTING)
  add_test(NAME python_tests
	       COMMAND nosetests --nocapture irispy
	       WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})

  add_test(NAME example_iris_2d
	       COMMAND jupyter nbconvert --to notebook --execute iris_2d.ipynb --output iris_2d.ipynb
	       WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/examples)

  add_test(NAME example_polyhedrons
           COMMAND jupyter nbconvert --to notebook --execute polyhedrons.ipynb --output polyhedrons.ipynb
           WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/examples)
endif()
