#include <iostream>
#include <Eigen/Core>
#include "iris/iris.h"

int main(int argc, char** argv) {
  iris::IRISProblem problem(2);
  problem.setSeedPoint(Eigen::Vector2d(0.1, 0.1));

  Eigen::MatrixXd obs(2,2);
  // Inflate a region inside a 1x1 box
  obs << 0, 1,
         0, 0;
  problem.addObstacle(obs);
  obs << 1, 1,
         0, 1;
  problem.addObstacle(obs);
  obs << 1, 0,
         1, 1;
  problem.addObstacle(obs);
  obs << 0, 0,
         1, 0;
  problem.addObstacle(obs);

  iris::IRISOptions options;
  iris::IRISRegion region = inflate_region(problem, options);

  std::cout << "C: " << region.ellipsoid.getC() << std::endl;
  std::cout << "d: " << region.ellipsoid.getD() << std::endl;
  return 0;
}