#include "iris/geometry.h"
#include <Eigen/Core>
#include <Eigen/LU>
#include <iostream>
#include "iris_cdd.h"

namespace iris {

int factorial(int n) {
  return n == 0 ? 1 : factorial(n - 1) * n;
}

double nSphereVolume(int dim, double radius) {
  double v;
  int k = std::floor(dim / 2);
  if (dim % 2 == 0) {
    v = std::pow(M_PI, k) / static_cast<double>(factorial(k));
  } else {
    v = (2.0 * factorial(k) * std::pow(4 * M_PI, k)) / static_cast<double>(factorial(2 * k + 1));
  }
  return v * std::pow(radius, dim);
}

Ellipsoid::Ellipsoid(int dim) :
  C_(Eigen::MatrixXd(dim, dim)),
  d_(Eigen::VectorXd(dim)) {}
Ellipsoid::Ellipsoid(Eigen::MatrixXd C, Eigen::VectorXd d):
  C_(C),
  d_(d) {}
const Eigen::MatrixXd& Ellipsoid::getC() const {
  return C_;
}
const Eigen::VectorXd& Ellipsoid::getD() const {
  return d_;
}
void Ellipsoid::setC(const Eigen::MatrixXd &C) {
  C_ = C;
}
void Ellipsoid::setCEntry(Eigen::DenseIndex row, 
                          Eigen::DenseIndex col, double value) {
  C_(row, col) = value;
}
void Ellipsoid::setD(const Eigen::VectorXd &d) {
  d_ = d;
}
void Ellipsoid::setDEntry(Eigen::DenseIndex index, double value) {
  d_(index) = value;
}
int Ellipsoid::getDimension() const {
  return C_.cols();
}
double Ellipsoid::getVolume() const {
  return C_.determinant() * nSphereVolume(this->getDimension(), 1.0);
}
Ellipsoid Ellipsoid::fromNSphere(Eigen::VectorXd &center, double radius) {
  const int dim = center.size();
  Eigen::MatrixXd C = Eigen::MatrixXd::Zero(dim, dim);
  C.diagonal().setConstant(radius);
  Ellipsoid ellipsoid(C, center);
  return ellipsoid;
}

Polyhedron::Polyhedron(int dim):
  A_(0, dim),
  b_(0, 1),
  dd_representation_dirty_(true) {}
Polyhedron::Polyhedron(Eigen::MatrixXd A, Eigen::VectorXd b):
    A_(A),
    b_(b),
    dd_representation_dirty_(true) {}
void Polyhedron::setA(const Eigen::MatrixXd &A) {
  A_ = A;
  dd_representation_dirty_ = true;
}
const Eigen::MatrixXd& Polyhedron::getA() const {
  return A_;
}
void Polyhedron::setB(const Eigen::VectorXd &b) {
  b_ = b;
  dd_representation_dirty_ = true;
}
const Eigen::VectorXd& Polyhedron::getB() const {
  return b_;
}
int Polyhedron::getDimension() const {
  return A_.cols();
}
int Polyhedron::getNumberOfConstraints() const {
  return A_.rows();
}
void Polyhedron::appendConstraints(const Polyhedron &other) {
  A_.conservativeResize(A_.rows() + other.getA().rows(), A_.cols());
  A_.bottomRows(other.getA().rows()) = other.getA();
  b_.conservativeResize(b_.rows() + other.getB().rows());
  b_.tail(other.getB().rows()) = other.getB();
  dd_representation_dirty_ = true;
}
void Polyhedron::updateDDRepresentation() {
  generator_points_.clear();
  generator_rays_.clear();
  getGenerators(A_, b_, generator_points_, generator_rays_);
  dd_representation_dirty_ = false;
}
std::vector<Eigen::VectorXd> Polyhedron::generatorPoints() {
  if (dd_representation_dirty_) {
    updateDDRepresentation();
  }
  return generator_points_;
}
std::vector<Eigen::VectorXd> Polyhedron::generatorRays() {
  if (dd_representation_dirty_) {
    updateDDRepresentation();
  }
  return generator_rays_;
}
bool Polyhedron::contains(Eigen::VectorXd point, double tolerance) {
  return (A_ * point - b_).maxCoeff() <= tolerance;
}

}