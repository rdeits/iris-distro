#ifndef _IRIS_TYPES_H
#define _IRIS_TYPES_H

#include <Eigen/Core>

class IRISOptions {
public:
  bool require_containment=false;
  bool error_on_infeas_start=false;
};

class Polytope {
public:
  Eigen::MatrixXd A;
  Eigen::VectorXd b;

  Polytope(int dim):
    A(0, dim),
    b(0, 1) {}

  Polytope(Eigen::MatrixXd A, Eigen::VectorXd b):
    A(A),
    b(b) {}

  int getDimension() const {
    return A.cols();
  }

  int getNumberOfConstraints() const {
    return A.rows();
  }

  void appendConstraints(const Polytope &other) {
    A.conservativeResize(A.rows() + other.A.rows(), A.cols());
    A.bottomRows(other.A.rows()) = other.A;
    b.conservativeResize(b.rows() + other.b.rows());
    b.tail(other.b.rows()) = other.b;
  }
};

class Ellipsoid {
public:
  Eigen::MatrixXd C;
  Eigen::VectorXd d;

  Ellipsoid(int dim):
    C(Eigen::MatrixXd(dim, dim)),
    d(Eigen::VectorXd(dim)) {}

  Ellipsoid(Eigen::MatrixXd C, Eigen::VectorXd d):
    C(C),
    d(d) {}

  double getDimension() const {
    return C.cols();
  }
};

class IRISRegion {
public:
  Polytope polytope;
  Ellipsoid ellipsoid;

  IRISRegion(int dim):
    polytope(dim),
    ellipsoid(dim)
    {}
};

struct IRISDebugData {
  std::vector<Ellipsoid> ellipsoid_history;
  std::vector<Polytope> polytope_history;
  Eigen::VectorXd start;
  std::vector<Eigen::MatrixXd> obstacles;
  Eigen::VectorXd ellipsoid_times;
  Eigen::VectorXd polytope_times;
  double total_time;
  int iters;
};

struct IRISProblem {
  IRISProblem(int dim):
    bounds(dim),
    dim(dim),
    start(dim) {}

  std::vector<Eigen::MatrixXd> obstacle_pts; // each obstacle is a matrix of size (_dim, pts_per_obstacle)
  Polytope bounds;
  int dim;
  Eigen::VectorXd start;
};

#endif