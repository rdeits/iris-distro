#ifndef _CVXGEN_LDP_H
#define _CVXGEN_LDP_H

#define IRIS_CVXGEN_LDP_MAX_ROWS 3
#define IRIS_CVXGEN_LDP_MAX_COLS 8

#ifdef __cplusplus
#include <Eigen/Core>
namespace iris_cvxgen {
  void closest_point_in_convex_hull(Eigen::MatrixXd Points, Eigen::VectorXd &result);
}
#endif

#ifdef __cplusplus
extern "C" {
#endif
  void iris_cvxgen_closest_point_in_convex_hull(double *Y, double *v);
#ifdef __cplusplus
}
#endif

#endif
