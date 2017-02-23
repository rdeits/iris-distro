#include "iris/cvxgen_ldp.h"
#include "solver.h"

Vars vars;
Params params;
Workspace work;
Settings settings;

void iris_cvxgen_closest_point_in_convex_hull(double *Y, double *v) {
  set_defaults();
  setup_indexing();
  settings.verbose = 0;
  settings.kkt_reg = 1e-8;
  double *src;
  double *dest;
  int i;
  src = Y;
  dest = params.Y;
  for (i = 0; i < 24; i++) {
  	*dest++ = *src++;
  }
  solve();
  dest = v;
  src = vars.v;
  for (i = 0; i < 3; i++) {
  	*dest++ = *src++;
  }
}
