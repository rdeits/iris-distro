#include "iris.h"

namespace iris {

void IRISProblem::setSeedPoint(Eigen::VectorXd point) {
  if (point.size() != this->getDimension()) {
    throw(std::runtime_error("seed point must match dimension dim"));
  }
  this->seed = Ellipsoid::fromNSphere(point);
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
void IRISProblem::setBounds(Polyhedron new_bounds) {
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
const std::vector<Eigen::MatrixXd>& IRISProblem::getObstacles() const {
  return this->obstacle_pts;
}
Polyhedron IRISProblem::getBounds() const {
  return this->bounds;
}

}