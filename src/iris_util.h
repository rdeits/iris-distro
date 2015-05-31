#ifndef _IRIS_UTIL_H
#define _IRIS_UTIL_H

#include <stdbool.h>
#include <stdlib.h>

typedef struct IRISOptions_t {
  bool require_containment;
  bool error_on_infeas_start;
} IRISOptions;

typedef struct Matrix_t {
  double *data;
  size_t rows;
  size_t cols;
} Matrix;

typedef struct Polytope_t {
  Matrix *A;
  Matrix *b;
  size_t num_faces;
  size_t dim;
} Polytope;

typedef struct Ellipsoid_t {
  Matrix *C;
  Matrix *d;
  size_t dim;
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
  Matrix* obstacle_pts; // dim x num_obstacles
  Polytope* bounds;
  Matrix* start; // dim x 1
} IRISProblem;

Matrix* construct_matrix(int rows, int cols);
void set_matrix_data(Matrix* matrix, int cols, double data[][cols]);
void free_matrix(Matrix* matrix);
Matrix* invert_matrix(Matrix* matrix);
double* index(Matrix* matrix, size_t row, size_t col);
void copy_matrix(Matrix* source, Matrix* destination);

Polytope* construct_polytope(int m, int n);
void append_polytope(Polytope* this, Polytope *other);
void free_polytope(Polytope* polytope);

Ellipsoid* construct_ellipsoid(int dim);
void free_ellipsoid(Ellipsoid* ellipsoid);



#endif