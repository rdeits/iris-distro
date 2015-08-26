#include "test_util.h"
#include "iris/iris.h"

int main() {
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
  auto region = inflate_region(problem, options);
  Eigen::MatrixXd C_expected(2,2);
  Eigen::VectorXd d_expected(2);
  C_expected << 0.5, 0, 
                0, 0.5;
  d_expected << 0.5, 0.5;
  valuecheckMatrix(region.ellipsoid.getC(), C_expected, 1e-3);
  valuecheckMatrix(region.ellipsoid.getD(), d_expected, 1e-3);

  return 0;
}

