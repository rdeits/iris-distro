#include "iris.h"
#include "iris_mosek.h"
#include "iris_ldp/solver.h"

#define ELLIPSOID_C_EPSILON 1e-4

using namespace Eigen;

void initialize_small_sphere(const VectorXd &start, Ellipsoid &ellipsoid) {
  assert(ellipsoid.getDimension() == start.size());
  ellipsoid.d = start;
  for (int i=0; i < ellipsoid.getDimension(); i++) {
    ellipsoid.C(i,i) = ELLIPSOID_C_EPSILON;
  }
}

int separating_hyperplanes(const std::vector<MatrixXd> obstacle_pts, const Ellipsoid &ellipsoid, Polytope &polytope) {
  return 0;
}

IRISRegion* inflate_region(const IRISProblem &problem, const IRISOptions &options=IRISOptions(), IRISDebugData *debug=NULL) {

  IRISRegion* region = new IRISRegion(problem.dim);
  initialize_small_sphere(problem.start, region->ellipsoid);

  double best_vol = pow(ELLIPSOID_C_EPSILON, problem.dim);
  double volume;
  long int iter = 0;

  while (1) {
    int err_infeasible_start = separating_hyperplanes(problem.obstacle_pts, region->ellipsoid, region->polytope);
    if (options.error_on_infeas_start && err_infeasible_start) {
      printf("Error: initial point is infeasible\n");
      return NULL;
    }

    region->polytope.appendConstraints(problem.bounds);

    inner_ellipsoid(region->polytope, region->ellipsoid, &volume);

    if ((abs(volume - best_vol) / best_vol) < 2e-2)
      break;

    best_vol = volume;
    iter++;
  }

  return region;
}


