%module iris_wrapper

%include "exception.i"
%exception {
  try {
    $action
  } catch (const std::exception& e) {
    SWIG_exception(SWIG_RuntimeError, e.what());
  } catch (...) {
    SWIG_exception(SWIG_RuntimeError, "Unknown error");
  }
}

%{
#define SWIG_FILE_WITH_INIT
#include <Python.h>
#include "iris/iris.h"
#include "iris/geometry.h"
%}

%include <typemaps.i>
%include <std_vector.i>
%include <eigen.i>

%template(vectorVectorXd) std::vector<Eigen::VectorXd>;
%template(vectorMatrixXd) std::vector<Eigen::MatrixXd>;
%template(vectorPolyhedron) std::vector<iris::Polyhedron>;
%template(vectorEllipsoid) std::vector<iris::Ellipsoid>;

%eigen_typemaps(Eigen::VectorXd)
%eigen_typemaps(Eigen::MatrixXd)
%eigen_typemaps(Eigen::Matrix<double, Eigen::Dynamic, Eigen::Dynamic>)

%feature("autodoc", "1");

%include "iris/geometry.h"
%include "iris/iris.h"

%pythoncode %{
import drawing
import extensions
Polyhedron.__bases__ += (drawing.DrawDispatcher, extensions.PolyhedronExtension)
Ellipsoid.__bases__ += (drawing.DrawDispatcher, extensions.EllipsoidExtension)
IRISDebugData.__bases__ += (extensions.IRISDebugDataExtension,)
setattr(Ellipsoid, "default_color", "b")
%}


