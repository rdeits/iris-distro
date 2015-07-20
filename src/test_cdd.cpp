#include <iostream>
#include "iris.hpp"

using namespace Eigen;

int main(int argc, char **argv) {
  MatrixXd A(4,2);
  A << 1, 0,
       0, 1,
       -1, 0,
       0, -1;
  VectorXd b(4);
  b << 1, 1, 0.5, 0.5;

  iris::Polytope poly(A, b);
  std::vector<VectorXd> points = poly.generatorPoints();

  for (auto pt = points.begin(); pt != points.end(); ++pt) {
    std::cout << pt->transpose() << std::endl;
  }

  return 0;
}