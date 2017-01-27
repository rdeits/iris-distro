#include <Eigen/Core>
#include "iris/iris.h"
#include "iris/iris_mosek.h"
#include "test_util.h"

int main() {
  Eigen::MatrixXd A(4,3);
  A << -1, 0, 0,
       0, -1, 0,
       0, 0, -1,
       1, 1, 1;
  Eigen::VectorXd b(4);
  b << 0, 0, 0, 1;
  iris::Polyhedron polyhedron(A, b);

  iris::Ellipsoid ellipsoid(3);

  iris_mosek::inner_ellipsoid(polyhedron, &ellipsoid);

  Eigen::MatrixXd C_expected(3,3);
  C_expected <<  0.2523,   -0.0740,   -0.0740,
                 -0.0740,    0.2523,   -0.0740,
                 -0.0740,   -0.0740,    0.2523;
  Eigen::VectorXd d_expected(3);
  d_expected << 0.2732, 0.2732, 0.2732;
  valuecheckMatrix(ellipsoid.getC(), C_expected, 1e-3);
  valuecheckMatrix(ellipsoid.getD(), d_expected, 1e-3);

  return 0;
}
