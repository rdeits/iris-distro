#ifndef _IRIS_UTIL_H
#define _IRIS_UTIL_H

#include <Eigen/Core>

struct IRISOptions {
  bool require_containment;
  bool error_on_infeas_start;
};

class Polytope {
public:
  Eigen::Matrix<double, Eigen::Dynamic, Eigen::Dynamic> A;
  Eigen::Matrix<double, Eigen::Dynamic, 1> b;

  double getDimension() const {
    return A.cols();
  }

  double getNumberOfConstraints() const {
    return A.rows();
  }
};

class Ellipsoid {
public:
  Eigen::Matrix<double, Eigen::Dynamic, Eigen::Dynamic> C;
  Eigen::Matrix<double, Eigen::Dynamic, 1> d;

  double getDimension() const {
    return C.cols();
  }
};

struct IRISRegion {
  Polytope polytope;
  Ellipsoid ellipsoid;
};

struct IRISDebugData {
  std::vector<Ellipsoid> ellipsoid_history;
  std::vector<Polytope> polytope_history;
  Eigen::Matrix<double, Eigen::Dynamic, 1> start;
  std::vector<Eigen::Matrix<double, Eigen::Dynamic, Eigen::Dynamic>> obstacles;
  Eigen::VectorXd ellipsoid_times;
  Eigen::VectorXd polytope_times;
  double total_time;
  int iters;
};

struct IRISProblem {
  std::vector<Eigen::Matrix<double, Eigen::Dynamic, Eigen::Dynamic>> obstacle_pts; // each obstacle is a matrix of size (_dim, pts_per_obstacle)
  Polytope bounds;
  Eigen::Matrix<double, Eigen::Dynamic, 1> start;
};

#endif