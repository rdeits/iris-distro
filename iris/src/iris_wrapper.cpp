#include <pybind11/pybind11.h>
#include "geometry.h"
#include "iris.h"

namespace py = pybind11;

PYBIND11_PLUGIN(iris_wrapper) {
  py::module m("iris_wrapper", "low-level bindings for IRIS");

  py::class_<iris::Polyhedron>(m, "Polyhedron")
    .def(py::init<int>());

  py::class_<iris::Ellipsoid>(m, "Ellipsoid")
    .def(py::init<int>());

  m.def("inflate_region", &iris::inflate_region, "Solve the given IRIS problem");

  py::class_<iris::IRISOptions>(m, "IRISOptions")
    .def(py::init<>());

  py::class_<iris::IRISRegion>(m, "IRISRegion")
    .def(py::init<int>());

  py::class_<iris::IRISProblem>(m, "IRISProblem")
    .def(py::init<int>());

  py::class_<iris::IRISDebugData>(m, "IRISDebugData")
    .def(py::init<>());

  return m.ptr();
}
