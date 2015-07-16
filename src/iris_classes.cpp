#include <iostream>
#include <numeric>
#include <Eigen/LU>
#include "iris.hpp"

using namespace Eigen;

Polytope::Polytope(int dim):
  A_(0, dim),
  b_(0, 1) {}
Polytope::Polytope(Eigen::MatrixXd A, Eigen::VectorXd b):
    A_(A),
    b_(b) {}
void Polytope::setA(const Eigen::MatrixXd &A) {
  A_ = A;
}
const Eigen::MatrixXd& Polytope::getA() const {
  return A_;
}
void Polytope::setB(const Eigen::VectorXd &b) {
  b_ = b;
}
const Eigen::VectorXd& Polytope::getB() const {
  return b_;
}
int Polytope::getDimension() const {
  return A_.cols();
}
int Polytope::getNumberOfConstraints() const {
  return A_.rows();
}
void Polytope::appendConstraints(const Polytope &other) {
  A_.conservativeResize(A_.rows() + other.getA().rows(), A_.cols());
  A_.bottomRows(other.getA().rows()) = other.getA();
  b_.conservativeResize(b_.rows() + other.getB().rows());
  b_.tail(other.getB().rows()) = other.getB();
}

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
const MatrixXd& Ellipsoid::getC() const {
  return C_;
}
const VectorXd& Ellipsoid::getD() const {
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
std::shared_ptr<Ellipsoid> Ellipsoid::fromNSphere(Eigen::VectorXd &center, double radius) {
  const int dim = center.size();
  MatrixXd C = MatrixXd::Zero(dim, dim);
  C.diagonal().setConstant(radius);
  std::shared_ptr<Ellipsoid> ellipsoid(new Ellipsoid(C, center));
  return ellipsoid;
}

void IRISProblem::setSeedPoint(Eigen::VectorXd point) {
  if (point.size() != this->getDimension()) {
    throw(std::runtime_error("seed point must match dimension dim"));
  }
  this->seed = *Ellipsoid::fromNSphere(point);
}
void IRISProblem::setSeedEllipsoid(Ellipsoid ellipsoid){
  if (ellipsoid.getDimension() != this->getDimension()) {
    throw std::runtime_error("seed ellipsoid must match dimension dim");
  }
  this->seed = ellipsoid;
}
int IRISProblem::getDimension() const {
  return this->dim;
}
Ellipsoid IRISProblem::getSeed() const {
  return this->seed;
}
void IRISProblem::setBounds(Polytope new_bounds) {
  if (new_bounds.getDimension() != this->getDimension()) {
    throw std::runtime_error("bounds must match dimension dim");
  }
  this->bounds = new_bounds;
}
void IRISProblem::addObstacle(Eigen::MatrixXd new_obstacle_vertices) {
  // std::cout << "adding obstacle: " << new_obstacle_vertices << std::endl;
  // std::cout << "dim: " << this->getDimension() << std::endl;
  if (new_obstacle_vertices.rows() != this->getDimension()) {
    throw std::runtime_error("new_obstacle_vertices must have dim rows");
  }
  this->obstacle_pts.push_back(new_obstacle_vertices);
}
std::vector<Eigen::MatrixXd> IRISProblem::getObstacles() const {
  return this->obstacle_pts;
}
Polytope IRISProblem::getBounds() const {
  return this->bounds;
}