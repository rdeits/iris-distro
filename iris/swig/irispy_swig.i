%module irispy_swig

%include <std_except.i>

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