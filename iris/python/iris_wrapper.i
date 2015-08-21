%module(directors="1") iris_wrapper

%{
#define SWIG_FILE_WITH_INIT
#include <Python.h>
#include "iris.hpp"
%}

%include <typemaps.i>
%include <eigen.i>

%eigen_typemaps(Eigen::VectorXd)
%eigen_typemaps(Eigen::MatrixXd)
%eigen_typemaps(Eigen::Matrix<double, Eigen::Dynamic, Eigen::Dynamic>)

%include "iris.hpp"

%feature("director") iris::Polyhedron;
%feature("director") iris::Ellipsoid;
%feature("director") iris::IRISProblem;
%feature("director") iris::IRISRegion;
