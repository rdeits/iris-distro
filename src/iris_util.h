#ifndef _IRIS_UTIL_H
#define _IRIS_UTIL_H

#include <stdbool.h>

typedef struct IRISOptions_t {
  bool require_containment;
  bool error_on_infeas_start;
} IRISOptions;

typedef struct Polytope_t {
  double** A;
  double* b;
  int m;
  int dim;
} Polytope;

typedef struct Ellipsoid_t {
  double** C;
  double* d;
  int dim;
} Ellipsoid;

typedef struct IRISRegion_t {
  Polytope* polytope;
  Ellipsoid* ellipsoid;
} IRISRegion;

typedef struct IRISDebugData_t {
  Ellipsoid* ellipsoid_history;
  Polytope* polytope_history;
  double* start;
  double** obstacles;
  double* ellipsoid_time;
  double* polytope_time;
  double total_time;
  int iters;
  int n_obs;
} IRISDebugData;

typedef struct IRISProblem_t {
  int num_obstacles;
  int dim;
  double** obstacle_pts; // dim x num_obstacles;
  Polytope* bounds;
  double* start; // dim
} IRISProblem;



#endif