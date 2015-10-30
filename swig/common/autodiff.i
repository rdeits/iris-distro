
%{
#ifdef SWIGPYTHON
  #define SWIG_FILE_WITH_INIT
  #include <Python.h>
#endif
#include <unsupported/Eigen/AutoDiff>
#include <iostream>
%}

%include "eigen.i"

%eigen_typemaps(Eigen::VectorXd)
%eigen_typemaps(Eigen::Matrix<double, Eigen::Dynamic, 1>)
%eigen_typemaps(Eigen::MatrixXd)
%eigen_typemaps(Eigen::Matrix<double, Eigen::Dynamic, Eigen::Dynamic>)

%import <Eigen/Core>
%import <unsupported/Eigen/src/AutoDiff>


%inline %{

template <typename DerType, int RowsAtCompileTime, int ColsAtCompileTime>
class AutoDiffWrapper: public Eigen::Matrix<Eigen::AutoDiffScalar<DerType>, RowsAtCompileTime, ColsAtCompileTime> {

  typedef Eigen::Matrix<Eigen::AutoDiffScalar<DerType>, RowsAtCompileTime, ColsAtCompileTime> BaseMatrix;

public:
  AutoDiffWrapper<DerType, RowsAtCompileTime, ColsAtCompileTime>() {}

  AutoDiffWrapper<DerType, RowsAtCompileTime, ColsAtCompileTime>(const Eigen::Matrix<Eigen::AutoDiffScalar<DerType>, RowsAtCompileTime, ColsAtCompileTime>& x): Eigen::Matrix<Eigen::AutoDiffScalar<DerType>, RowsAtCompileTime, ColsAtCompileTime>(x) {};

  AutoDiffWrapper<DerType, RowsAtCompileTime, ColsAtCompileTime>(const Eigen::Matrix<double, RowsAtCompileTime, ColsAtCompileTime> &value, const Eigen::MatrixXd &derivatives) {
    this->resize(value.rows(), value.cols());
    if (derivatives.rows() != value.size()) {
      throw std::runtime_error("derivatives must have one row for every element in value");
    }
    for (size_t i=0; i < value.rows(); i++) {
      for (size_t j=0; j < value.cols(); j++) {
        this->coeffRef(i, j) = Eigen::AutoDiffScalar<Eigen::VectorXd>(value(i,j), derivatives.row(i + value.rows() * j));
      }
    }
  }

  Eigen::Matrix<double, RowsAtCompileTime, ColsAtCompileTime> value() {
    Eigen::Matrix<double, RowsAtCompileTime, ColsAtCompileTime> result(this->rows(), this->cols());
    for (size_t i=0; i < this->size(); i++) {
      result(i) = this->coeffRef(i).value();
    }
    return result;
  }

  Eigen::MatrixXd derivatives() {
    Eigen::MatrixXd result(this->size(), this->size() > 0 ? this->coeffRef(0).derivatives().size() : 0);
    for (int i=0; i < this->size(); i++) {
      if (this->coeffRef(i).derivatives().size() > result.cols()) {
        result.conservativeResize(result.rows(), this->coeffRef(i).derivatives().size());
      }
      for (int j=0; j < this->coeffRef(i).derivatives().size(); j++) {
        result(i, j) = this->coeffRef(i).derivatives()(j);
      }
    }
    return result;
  }

  AutoDiffWrapper<DerType, RowsAtCompileTime, ColsAtCompileTime> operator+ (const AutoDiffWrapper<DerType, RowsAtCompileTime, ColsAtCompileTime>& other) {
    return BaseMatrix::operator+(other).eval();
  }
  AutoDiffWrapper<DerType, RowsAtCompileTime, ColsAtCompileTime> operator- (const AutoDiffWrapper<DerType, RowsAtCompileTime, ColsAtCompileTime>& other) {
    return BaseMatrix::operator-(other).eval();
  }
  AutoDiffWrapper<DerType, RowsAtCompileTime, ColsAtCompileTime> arrayMultiply (const AutoDiffWrapper<DerType, RowsAtCompileTime, ColsAtCompileTime>& other) {
    return this->array().operator*(other.array()).matrix().eval();
  }
  AutoDiffWrapper<DerType, RowsAtCompileTime, ColsAtCompileTime> arrayDivide (const AutoDiffWrapper<DerType, RowsAtCompileTime, ColsAtCompileTime>& other) {
    return this->array().operator/(other.array()).matrix().eval();
  }

  AutoDiffWrapper<DerType, RowsAtCompileTime, ColsAtCompileTime> operator+ (double other) {
    return this->array().operator+(other).matrix().eval();
  }
  AutoDiffWrapper<DerType, RowsAtCompileTime, ColsAtCompileTime> operator- (double other) {
    return this->array().operator-(other).matrix().eval();
  }
  AutoDiffWrapper<DerType, RowsAtCompileTime, ColsAtCompileTime> operator* (double other) {
    return BaseMatrix::operator*(other).eval();
  }
  AutoDiffWrapper<DerType, RowsAtCompileTime, ColsAtCompileTime> operator/ (double other) {
    return BaseMatrix::operator/(other).eval();
  }

  int rows() const {
    return BaseMatrix::rows();
  }

  int cols() const {
    return BaseMatrix::cols();
  }

  int size() const {
    return BaseMatrix::size();
  }
};

%}

