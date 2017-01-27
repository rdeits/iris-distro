#include <iostream>
#include "iris/iris.h"
#include "test_util.h"

using namespace Eigen;

int main(int argc, char **argv) {
  MatrixXd A(4,2);
  A << 1, 0,
       0, 1,
       -1, 0,
       0, -1;
  VectorXd b(4);
  b << 1, 1, 0.5, 0.5;

  iris::Polyhedron poly(A, b);
  std::vector<VectorXd> points = poly.generatorPoints();

  for (auto pt = points.begin(); pt != points.end(); ++pt) {
    std::cout << pt->transpose() << std::endl;
  }


  MatrixXd pts_expected(2,4);
  pts_expected << -0.5, 1.0, 1.0, -0.5,
                  -0.5, -0.5, 1.0, 1.0;

  for (auto pt = points.begin(); pt != points.end(); ++pt) {
    valuecheckMatrix(*pt, pts_expected.col(pt - points.begin()), 1e-6);
  }

  return 0;
}