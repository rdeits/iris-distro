#include "test_util.h"
#include "iris/iris.h"

int main() {
  // Run IRIS with the required_containment_points including a point which is outside the feasible set, which should result in an empty polyhedron

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
  options.require_containment = true;
  std::vector<Eigen::VectorXd> required_containment_points = {Eigen::Vector2d(1.5, 1.5)};
  options.required_containment_points = required_containment_points;

  auto region = inflate_region(problem, options);
  if (region.polyhedron.getNumberOfConstraints() > 0) {
    throw std::runtime_error("polyhedron should be empty");
  }

  return 0;
}