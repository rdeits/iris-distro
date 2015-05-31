#include "iris_util.h"

IRISRegion* inflate_region(IRISProblem* problem, IRISOptions* options, IRISDebugData* debug);

void initialize_small_sphere(Ellipsoid* ellipsoid, Matrix* start);

int separating_hyperplanes(double** obstacle_pts, Ellipsoid* ellipsoid, Polytope* polytope);
