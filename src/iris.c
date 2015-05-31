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

// LU decomoposition of a general matrix
void dgetrf_(int* M, int *N, double* A, int* lda, int* ipiv, int* info);

// generate inverse of a matrix given its LU decomposition
void dgetri_(int* N, double* A, int* lda, int* ipiv, double* work, int* lwork, int* info);

double** construct_matrix(int rows, int cols) {
  double** matrix = malloc(rows * sizeof(double*));
  for (int i=0; i < rows; i++) {
    matrix[i] = malloc(cols * sizeof(double));
  }
  return matrix;
}

void free_matrix(double** matrix, int rows) {
  for (int i=0; i < rows; i++)
    free(matrix[i]);
  free(matrix);
}

void invert_matrix(int dim, double matrix[dim][dim], double inv[dim][dim]) {
  for (int i=0; i < dim; i++) {
    for (int j=0; j < dim; j++) {
      inv[i][j] = matrix[i][j];
    }
  }

  int* ipiv = malloc(sizeof(int) * (dim));
  int lwork = dim * dim;
  double work;
  int info;
  dgetrf_(&dim, &dim, &inv[0][0], &dim, ipiv, &info);
  dgetri_(&dim, &inv[0][0], &dim, ipiv, &work, &lwork, &info);

  free(ipiv);
}

Polytope* construct_polytope(int m, int n) {
  Polytope* polytope = malloc(sizeof(Polytope));
  polytope->m = m;
  polytope->dim = n;
  polytope->A = construct_matrix(m, n);
  polytope->b = malloc(m * sizeof(double));
  return polytope;
}

void append_polytope(Polytope* this, Polytope *other) {
  // Modify this in place by adding the rows from other
  assert(this->dim == other->dim);
  this->A = realloc(this->A, (this->m + other->m) * sizeof(double*));
  for (int i=0; i < other->m; i++) {
    this->A[this->m + i] = malloc(this->dim * sizeof(double));
    memcpy(this->A[this->m + i], other->A[i], this->dim * sizeof(double));
  }
  this->b = realloc(this->b, (this->m + other->m) * sizeof(double));
  memcpy(this->b + this->m, other->b, other->m * sizeof(double));
  this->m += other->m;
}

void free_polytope(Polytope* polytope) {
  free_matrix(polytope->A, polytope->m);
  free(polytope->b);
  free(polytope);
}

Ellipsoid* construct_ellipsoid(int dim) {
  Ellipsoid* ellipsoid = malloc(sizeof(Ellipsoid));
  ellipsoid->dim = dim;
  ellipsoid->C = construct_matrix(dim, dim);
  ellipsoid->d = malloc(dim * sizeof(double));
  return ellipsoid;
}

void free_ellipsoid(Ellipsoid* ellipsoid) {
  free_matrix(ellipsoid->C, ellipsoid->dim);
  free(ellipsoid->d);
  free(ellipsoid);
}

void initialize_small_sphere(Ellipsoid* ellipsoid, double* start) {
  memcpy(ellipsoid->d, start, sizeof(double) * ellipsoid->dim);
  for (int i=0; i < ellipsoid->dim; i++) {
    ellipsoid->C[i][i] = ELLIPSOID_C_EPSILON;
  }
}

int separating_hyperplanes(double** obstacle_pts, Ellipsoid* ellipsoid, Polytope* polytope) {

  return 0;
}

