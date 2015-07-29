#include <Eigen/Core>
#include "iris/iris.hpp"
#include "iris/iris_mosek.hpp"
#include "test_util.hpp"

int main() {
  Eigen::MatrixXd A(3,2);
  A << -1, 0,
        0, -1,
        1, 1;
  Eigen::VectorXd b(3);
  b << 0, 0, -1;
  iris::Polyhedron polyhedron(A, b);

  iris::Ellipsoid ellipsoid(2);

  
  try {
    iris_mosek::inner_ellipsoid(polyhedron, &ellipsoid);
  } catch (iris_mosek::InnerEllipsoidInfeasibleError &e) {
    return 0;
  }
  throw(std::runtime_error("expected an infeasible ellipsoid error"));
  return 1;
}