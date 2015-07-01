#include "solver.h"
#include "cvxgen_ldp.h"
Vars vars;
Params params;
Workspace work;
Settings settings;

void cvxgen_ldp(double *Y, double *v) {
  set_defaults();
  setup_indexing();
  settings.verbose = 0;
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


