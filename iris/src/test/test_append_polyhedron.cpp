#include "test_util.h"
#include <Eigen/Core>
#include "iris/iris.h"

int main () {

  Eigen::MatrixXd A(3,2);
  A << -1, 0,
       0, -1,
       1, 1;
  Eigen::VectorXd b(3);
  b << 0, 0, 1;
  iris::Polyhedron p(A, b);

  Eigen::MatrixXd A2(2,2);
  A2 << 2, 3,
        4, 5;
  Eigen::VectorXd b2(2);
  b2 << 6, 7;
  iris::Polyhedron other(A2, b2);

  p.appendConstraints(other);

  valuecheck(p.getNumberOfConstraints(), 5);
  Eigen::MatrixXd A_expected(5,2);
  A_expected << -1, 0,
                 0, -1,
                 1, 1,
                 2, 3,
                 4, 5;
  valuecheckMatrix(p.getA(), A_expected, 1e-12);

  return 0;
}