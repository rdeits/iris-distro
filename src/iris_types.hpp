#ifndef _IRIS_TYPES_H
#define _IRIS_TYPES_H

#include <Eigen/Core>
#include <vector>
#include <stdexcept>
#include <iostream>

#define ELLIPSOID_C_EPSILON 1e-4

class IRISOptions {
public:
  bool require_containment = false;
  bool error_on_infeas_start = false;
  double termination_threshold = 2e-2;
};

class Polytope {
public:
  Eigen::MatrixXd A;
  Eigen::VectorXd b;

  Polytope(int dim=0):
    A(0, dim),
    b(0, 1) {}

  Polytope(Eigen::MatrixXd A, Eigen::VectorXd b):
    A(A),
    b(b) {}

  void setA(Eigen::MatrixXd &A_) {
    A = A_;
  }

  const Eigen::MatrixXd& getA() const {
    return A;
  }

  void setB(const Eigen::VectorXd &b_) {
    b = b_;
  }

  const Eigen::VectorXd& getB() const {
    return b;
  }

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

  Ellipsoid(int dim=0):
    C(Eigen::MatrixXd(dim, dim)),
    d(Eigen::VectorXd(dim)) {}

  Ellipsoid(Eigen::MatrixXd C, Eigen::VectorXd d):
    C(C),
    d(d) {}

  const Eigen::MatrixXd& getC() const {
    return C;
  }

  const Eigen::VectorXd& getD() const {
    return d;
  }

  void setC(const Eigen::MatrixXd &C_) {
    C = C_;
  }

  void setD(const Eigen::VectorXd &d_) {
    d = d_;
  }

  double getDimension() const {
    return C.cols();
  }

  static Ellipsoid fromNSphere(Eigen::VectorXd &center, double radius=ELLIPSOID_C_EPSILON) {
    int dim = center.size();
    Ellipsoid ellipsoid(dim);
    ellipsoid.C.setZero();
    ellipsoid.C.diagonal().setConstant(radius);
    ellipsoid.d = center;
    return ellipsoid;
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
  std::vector<Eigen::MatrixXd> obstacles;
  Eigen::VectorXd ellipsoid_times;
  Eigen::VectorXd polytope_times;
  double total_time;
  int iters;
};

class IRISProblem {
private:
  std::vector<Eigen::MatrixXd> obstacle_pts; // each obstacle is a matrix of size (_dim, pts_per_obstacle)
  Polytope bounds;
  int dim;
  Ellipsoid seed;

public:
  IRISProblem(int dim):
    bounds(dim),
    dim(dim),
    seed(dim) {}

  void setSeedPoint(Eigen::VectorXd point) {
    if (point.size() != this->getDimension()) {
      throw(std::runtime_error("seed point must match dimension dim"));
    }
    this->seed = Ellipsoid::fromNSphere(point);
  }

  void setSeedEllipsoid(Ellipsoid ellipsoid){
    if (ellipsoid.getDimension() != this->getDimension()) {
      throw std::runtime_error("seed ellipsoid must match dimension dim");
    }
    this->seed = ellipsoid;
  }

  int getDimension() const {
    return this->dim;
  }

  Ellipsoid getSeed() const {
    return this->seed;
  }

  void setBounds(Polytope new_bounds) {
    if (new_bounds.getDimension() != this->getDimension()) {
      throw std::runtime_error("bounds must match dimension dim");
    }
    this->bounds = new_bounds;
  }

  void addObstacle(Eigen::MatrixXd new_obstacle_vertices) {
    if (new_obstacle_vertices.rows() != this->getDimension()) {
      throw std::runtime_error("new_obstacle_vertices must have dim rows");
    }
    this->obstacle_pts.push_back(new_obstacle_vertices);
  }

  std::vector<Eigen::MatrixXd> getObstacles() const {
    return this->obstacle_pts;
  }

  Polytope getBounds() const {
    return this->bounds;
  }

};

#endif