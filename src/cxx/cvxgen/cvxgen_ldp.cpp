#include <stdexcept>
#include "iris/cvxgen_ldp.h"

using namespace Eigen;

namespace iris_cvxgen {
  void closest_point_in_convex_hull(MatrixXd Points, VectorXd &result) {
    int m = Points.rows();
    int n = Points.cols();
    if (m < IRIS_CVXGEN_LDP_MAX_ROWS || n < IRIS_CVXGEN_LDP_MAX_COLS) {
      Points.conservativeResize(IRIS_CVXGEN_LDP_MAX_ROWS, IRIS_CVXGEN_LDP_MAX_COLS);
    } else if (m > IRIS_CVXGEN_LDP_MAX_ROWS) {
      throw(std::runtime_error("Too many rows for CVXGEN solver"));
    } else if (n > IRIS_CVXGEN_LDP_MAX_COLS) {
      throw(std::runtime_error("Too many cols for CVXGEN solver"));
    }

    if (m < IRIS_CVXGEN_LDP_MAX_ROWS) {
      Points.bottomRows(IRIS_CVXGEN_LDP_MAX_ROWS - m).setZero();
    }
    for (int i=n; i < IRIS_CVXGEN_LDP_MAX_COLS; i++) {
      Points.col(i) = Points.col(n - 1);
    }

    // std::cout << "resized points: " << std::endl << Points << std::endl;
    VectorXd resized_result(IRIS_CVXGEN_LDP_MAX_ROWS);
    iris_cvxgen_closest_point_in_convex_hull(Points.data(), resized_result.data());
    result = resized_result.head(m);
    return;
  }
}
