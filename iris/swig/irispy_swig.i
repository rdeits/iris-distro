%module(directors="1") irispy_swig

%include <std_except.i>

%include <exception.i>

%{
#define SWIG_FILE_WITH_INIT
#include <Python.h>
#include "iris.hpp"
%}

%init
%{
	import_array();
%}

%include <typemaps.i>
%include <std_vector.i>
%include <eigen.i>

%eigen_typemaps(Eigen::VectorXd)
%eigen_typemaps(Eigen::MatrixXd)

%include "iris.hpp"

%feature("director") iris::Polyhedron;
%feature("director") iris::Ellipsoid;
%feature("director") iris::IRISProblem;
%feature("director") iris::IRISRegion;

%template(VectorXdVector) std::vector<Eigen::VectorXd>;
