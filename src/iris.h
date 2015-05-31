#include "iris_util.h"

IRISRegion* inflate_region(IRISProblem* problem, IRISOptions* options, IRISDebugData* debug);

double** construct_matrix(int rows, int cols);
void free_matrix(double** matrix, int rows);
void invert_matrix(int dim, double matrix[dim][dim], double inv[dim][dim]);

Polytope* construct_polytope(int m, int n);
void append_polytope(Polytope* this, Polytope *other);
void free_polytope(Polytope* polytope);

Ellipsoid* construct_ellipsoid(int dim);
void free_ellipsoid(Ellipsoid* ellipsoid);

void initialize_small_sphere(Ellipsoid* ellipsoid, double* start);

int separating_hyperplanes(double** obstacle_pts, Ellipsoid* ellipsoid, Polytope* polytope);
