set -e
mkdir -p build
cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=install -DPYBIND11_PYTHON_VERSION=$PYBIND11_PYTHON_VERSION ..
make
cd iris_project-prefix/src/iris_project-build
ctest --output-on-failure
set +e
