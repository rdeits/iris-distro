#include <math.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>
#include "iris.h"
#include "iris_mosek.h"
#include "iris_ldp/solver.h"

#define ELLIPSOID_C_EPSILON 1e-4

IRISRegion* inflate_region(IRISProblem* problem, IRISOptions* options, IRISDebugData* debug) {
  bool got_options = (bool) options;
  if (!got_options) {
    options = (IRISOptions*) malloc(sizeof(IRISOptions));
    options->require_containment = false;
    options->error_on_infeas_start = false;
  }

  IRISRegion* region = malloc(sizeof(IRISRegion));
  region->polytope = construct_polytope(0, problem->dim);
  region->ellipsoid = construct_ellipsoid(problem->dim);
  initialize_small_sphere(region->ellipsoid, problem->start);

  double best_vol = pow(ELLIPSOID_C_EPSILON, problem->dim);
  double volume;
  long int iter = 0;

  while (1) {
    int err_infeasible_start = separating_hyperplanes(problem->obstacle_pts, region->ellipsoid, region->polytope);
    if (options->error_on_infeas_start && err_infeasible_start) {
      printf("Error: initial point is infeasible\n");
      return NULL;
    }

    append_polytope(region->polytope, problem->bounds);

    inner_ellipsoid(region->polytope, region->ellipsoid, &volume);

    if ((abs(volume - best_vol) / best_vol) < 2e-2)
      break;

    best_vol = volume;
    iter++;
  }

  if (!got_options) {
    free(options);
  }

  return region;
}

void initialize_small_sphere(Ellipsoid* ellipsoid, Matrix* start) {
  assert(ellipsoid->dim == start->rows);
  copy_matrix(start, ellipsoid->d);
  for (int i=0; i < ellipsoid->dim; i++) {
    *index(ellipsoid->C, i, i) = ELLIPSOID_C_EPSILON;
  }
}

int separating_hyperplanes(double** obstacle_pts, Ellipsoid* ellipsoid, Polytope* polytope) {

  return 0;
}

