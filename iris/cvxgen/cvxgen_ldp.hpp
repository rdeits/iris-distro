#ifndef _CVXGEN_LDP_HPP
#define _CVXGEN_LDP_HPP

#include <Eigen/Core>

#define IRIS_CVXGEN_LDP_MAX_ROWS 3
#define IRIS_CVXGEN_LDP_MAX_COLS 8

namespace iris_cvxgen {
  void closest_point_in_convex_hull(Eigen::MatrixXd Points, Eigen::VectorXd &result);
}


#endif
