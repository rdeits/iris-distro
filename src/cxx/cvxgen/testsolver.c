/* Produced by CVXGEN, 2014-05-20 16:06:22 -0400.  */
/* CVXGEN is Copyright (C) 2006-2012 Jacob Mattingley, jem@cvxgen.com. */
/* The code in this file is Copyright (C) 2006-2012 Jacob Mattingley. */
/* CVXGEN, or solvers produced by CVXGEN, cannot be used for commercial */
/* applications without prior written permission from Jacob Mattingley. */

/* Filename: testsolver.c. */
/* Description: Basic test harness for solver.c. */
#include "solver.h"
Vars vars;
Params params;
Workspace work;
Settings settings;
#define NUMTESTS 1000
int main(int argc, char **argv) {
  int num_iters;
#if (NUMTESTS > 0)
  int i;
  double time;
  double time_per;
#endif
  set_defaults();
  setup_indexing();
  load_default_data();
  /* Solve problem instance for the record. */
  settings.verbose = 1;
  num_iters = solve();
#ifndef ZERO_LIBRARY_MODE
#if (NUMTESTS > 0)
  /* Now solve multiple problem instances for timing purposes. */
  settings.verbose = 0;
  tic();
  for (i = 0; i < NUMTESTS; i++) {
    solve();
  }
  time = tocq();
  printf("Timed %d solves over %.3f seconds.\n", NUMTESTS, time);
  time_per = time / NUMTESTS;
  if (time_per > 1) {
    printf("Actual time taken per solve: %.3g s.\n", time_per);
  } else if (time_per > 1e-3) {
    printf("Actual time taken per solve: %.3g ms.\n", 1e3*time_per);
  } else {
    printf("Actual time taken per solve: %.3g us.\n", 1e6*time_per);
  }
#endif
#endif
  return 0;
}
void load_default_data(void) {
  params.Y[0] = 0.20319161029830202;
  params.Y[1] = 0.8325912904724193;
  params.Y[2] = -0.8363810443482227;
  params.Y[3] = 0.04331042079065206;
  params.Y[4] = 1.5717878173906188;
  params.Y[5] = 1.5851723557337523;
  params.Y[6] = -1.497658758144655;
  params.Y[7] = -1.171028487447253;
  params.Y[8] = -1.7941311867966805;
  params.Y[9] = -0.23676062539745413;
  params.Y[10] = -1.8804951564857322;
  params.Y[11] = -0.17266710242115568;
  params.Y[12] = 0.596576190459043;
  params.Y[13] = -0.8860508694080989;
  params.Y[14] = 0.7050196079205251;
  params.Y[15] = 0.3634512696654033;
  params.Y[16] = -1.9040724704913385;
  params.Y[17] = 0.23541635196352795;
  params.Y[18] = -0.9629902123701384;
  params.Y[19] = -0.3395952119597214;
  params.Y[20] = -0.865899672914725;
  params.Y[21] = 0.7725516732519853;
  params.Y[22] = -0.23818512931704205;
  params.Y[23] = -1.372529046100147;
}
