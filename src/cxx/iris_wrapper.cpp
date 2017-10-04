#include <pybind11/pybind11.h>
#include <pybind11/eigen.h>
#include <pybind11/stl.h>

#include "iris/geometry.h"
#include "iris/iris.h"
#include "iris/iris_mosek.h"

namespace py = pybind11;

PYBIND11_PLUGIN(iris_wrapper) {
  py::module m("iris_wrapper", "low-level bindings for IRIS");

  py::class_<iris::Polyhedron>(m, "Polyhedron")
    .def(py::init<int>())
    .def(py::init<>())
    .def(py::init<Eigen::MatrixXd, Eigen::VectorXd>())
    .def("setA", &iris::Polyhedron::setA)
    .def("getA", &iris::Polyhedron::getA)
    .def("setB", &iris::Polyhedron::setB)
    .def("getB", &iris::Polyhedron::getB)
    .def("getDimension", &iris::Polyhedron::getDimension)
    .def("getNumberOfConstraints", &iris::Polyhedron::getNumberOfConstraints)
    .def("appendConstraints", &iris::Polyhedron::appendConstraints)
    .def("generatorPoints", &iris::Polyhedron::generatorPoints)
    .def("generatorRays", &iris::Polyhedron::generatorRays)
    .def("contains", &iris::Polyhedron::contains)
    ;

  py::class_<iris::Ellipsoid>(m, "Ellipsoid")
    .def(py::init<int>())
    .def(py::init<>())
    .def(py::init<Eigen::MatrixXd, Eigen::VectorXd>())
    .def("getC", &iris::Ellipsoid::getC)
    .def("getD", &iris::Ellipsoid::getD)
    .def("setC", &iris::Ellipsoid::setC)
    .def("setCEntry", &iris::Ellipsoid::setCEntry)
    .def("setD", &iris::Ellipsoid::setD)
    .def("setDEntry", &iris::Ellipsoid::setDEntry)
    .def("getDimension", &iris::Ellipsoid::getDimension)
    .def_static("fromNSphere", &iris::Ellipsoid::fromNSphere, py::arg("center"), py::arg("radius")=iris::ELLIPSOID_C_EPSILON)
    .def("getVolume", &iris::Ellipsoid::getVolume)
    ;

  m.def("inflate_region", &iris::inflate_region, "Solve the given IRIS problem", py::arg("IRISProblem"), py::arg("IRISOptions"), py::arg("debug") = nullptr);

  m.def("inner_ellipsoid", 
        [](const iris::Polyhedron &polyhedron) {
              // iris::Ellipsoid* ellipsoid = new iris::Ellipsoid(polyhedron.getDimension());
              iris::Ellipsoid ellipsoid(polyhedron.getDimension());
              iris_mosek::inner_ellipsoid(polyhedron, &ellipsoid);
              return ellipsoid;
        });

  py::class_<iris::IRISOptions>(m, "IRISOptions")
    .def(py::init<>())
    .def_readwrite("require_containment", &iris::IRISOptions::require_containment)
    .def_readwrite("error_on_infeasible_start", &iris::IRISOptions::error_on_infeasible_start)
    .def_readwrite("termination_threshold", &iris::IRISOptions::termination_threshold)
    .def_readwrite("iter_limit", &iris::IRISOptions::iter_limit)
    .def_readwrite("required_containment_points", &iris::IRISOptions::required_containment_points)
    ;

  py::class_<iris::IRISRegion>(m, "IRISRegion")
    .def(py::init<int>())
    .def("getPolyhedron", &iris::IRISRegion::getPolyhedron)
    .def("getEllipsoid", &iris::IRISRegion::getEllipsoid)
    .def_readonly("polyhedron", &iris::IRISRegion::polyhedron)
    .def_readonly("ellipsoid", &iris::IRISRegion::ellipsoid)
    ;

  py::class_<iris::IRISProblem>(m, "IRISProblem")
    .def(py::init<int>())
    .def("setSeedPoint", &iris::IRISProblem::setSeedPoint)
    .def("setSeedEllipsoid", &iris::IRISProblem::setSeedEllipsoid)
    .def("getDimension", &iris::IRISProblem::getDimension)
    .def("getSeed", &iris::IRISProblem::getSeed)
    .def("setBounds", &iris::IRISProblem::setBounds)
    .def("addObstacle", &iris::IRISProblem::addObstacle)
    .def("getObstacles", &iris::IRISProblem::getObstacles)
    .def("getBounds", &iris::IRISProblem::getBounds)
    ;

  py::class_<iris::IRISDebugData>(m, "IRISDebugData")
    .def(py::init<>())
    .def_readonly("ellipsoid_history", &iris::IRISDebugData::ellipsoid_history)
    .def_readonly("polyhedron_history", &iris::IRISDebugData::polyhedron_history)
    .def_readonly("obstacles", &iris::IRISDebugData::obstacles)
    .def_readonly("bounds", &iris::IRISDebugData::bounds)
    .def_readonly("iters", &iris::IRISDebugData::iters)
    .def("boundingPoints", &iris::IRISDebugData::boundingPoints)
    .def("getObstacles", &iris::IRISDebugData::getObstacles)
    ;

  return m.ptr();
}
