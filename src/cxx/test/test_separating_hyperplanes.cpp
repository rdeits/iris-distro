#include <Eigen/Core>
#include "iris/iris.h"
#include "test_util.h"

int main() {
  // A simple example with a sphere centered at the origin
  Eigen::MatrixXd C(2,2);
  C << 1, 0,
       0, 1;
  Eigen::VectorXd d(2);
  d << 0, 0;
  iris::Ellipsoid ellipsoid(C, d);

  Eigen::MatrixXd obs(2,4);
  obs << 2, 3, 3, 2,
         2, 2, 3, 3;
  std::vector<Eigen::MatrixXd> obstacles;
  obstacles.push_back(obs);

  iris::Polyhedron result(2);
  bool infeasible_start;
  iris::separating_hyperplanes(obstacles, ellipsoid, result, infeasible_start);
  valuecheck(infeasible_start, false);
  Eigen::MatrixXd A_expected(1, 2);
  A_expected << 1/std::sqrt(2), 1/std::sqrt(2);
  Eigen::VectorXd b_expected(1);
  b_expected << 2.0 * 2.0 * 1.0/std::sqrt(2);
  valuecheckMatrix(result.getA(), A_expected, 1e-6);
  valuecheckMatrix(result.getB(), b_expected, 1e-6);

  return 0;
}