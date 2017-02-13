#include "iris/iris.h"
#include <stdexcept>

namespace iris {

void IRISProblem::setSeedPoint(Eigen::VectorXd point) {
  if (point.size() != this->getDimension()) {
    throw(std::runtime_error("The dimension of the seed point must match the dimension of the problem"));
  }
  this->seed = Ellipsoid::fromNSphere(point);
}
void IRISProblem::setSeedEllipsoid(Ellipsoid ellipsoid){
  if (ellipsoid.getDimension() != this->getDimension()) {
    throw std::runtime_error("The dimension of the seed ellipsoid must match the dimension of the problem");
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
    throw std::runtime_error("The dimension of the bounds must match the dimension of the problem");
  }
  this->bounds = new_bounds;
}
void IRISProblem::addObstacle(Eigen::MatrixXd new_obstacle_vertices) {
  if (new_obstacle_vertices.rows() != this->getDimension()) {
    throw std::runtime_error("The matrix of obstacle vertices must have the same number of row as the dimension of the problem");
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