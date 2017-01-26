#include <Eigen/Core>
#include "iris/iris.h"
#include "iris/iris_mosek.h"
#include "test_util.h"

int main() {
  Eigen::MatrixXd A(3,2);
  A << -1, 0,
        0, -1,
        1, 1;
  Eigen::VectorXd b(3);
  b << 0, 0, 1;
  iris::Polyhedron polyhedron(A, b);

  iris::Ellipsoid ellipsoid(2);

  iris_mosek::inner_ellipsoid(polyhedron, &ellipsoid);

  Eigen::MatrixXd C_expected(2,2);
  C_expected << 0.332799, -0.132021,
                -0.132021, 0.332799;
  Eigen::VectorXd d_expected(2);
  d_expected << 0.358029, 0.358029;
  valuecheckMatrix(ellipsoid.getC(), C_expected, 1e-5);
  valuecheckMatrix(ellipsoid.getD(), d_expected, 1e-5);

  return 0;
}