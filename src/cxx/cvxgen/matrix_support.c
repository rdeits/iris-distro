/* Produced by CVXGEN, 2014-05-20 16:06:21 -0400.  */
/* CVXGEN is Copyright (C) 2006-2012 Jacob Mattingley, jem@cvxgen.com. */
/* The code in this file is Copyright (C) 2006-2012 Jacob Mattingley. */
/* CVXGEN, or solvers produced by CVXGEN, cannot be used for commercial */
/* applications without prior written permission from Jacob Mattingley. */

/* Filename: matrix_support.c. */
/* Description: Support functions for matrix multiplication and vector filling. */
#include "solver.h"
void multbymA(double *lhs, double *rhs) {
  lhs[0] = -rhs[0]*(-1)-rhs[3]*(params.Y[0])-rhs[4]*(params.Y[3])-rhs[5]*(params.Y[6])-rhs[6]*(params.Y[9])-rhs[7]*(params.Y[12])-rhs[8]*(params.Y[15])-rhs[9]*(params.Y[18])-rhs[10]*(params.Y[21]);
  lhs[1] = -rhs[1]*(-1)-rhs[3]*(params.Y[1])-rhs[4]*(params.Y[4])-rhs[5]*(params.Y[7])-rhs[6]*(params.Y[10])-rhs[7]*(params.Y[13])-rhs[8]*(params.Y[16])-rhs[9]*(params.Y[19])-rhs[10]*(params.Y[22]);
  lhs[2] = -rhs[2]*(-1)-rhs[3]*(params.Y[2])-rhs[4]*(params.Y[5])-rhs[5]*(params.Y[8])-rhs[6]*(params.Y[11])-rhs[7]*(params.Y[14])-rhs[8]*(params.Y[17])-rhs[9]*(params.Y[20])-rhs[10]*(params.Y[23]);
  lhs[3] = -rhs[3]*(1)-rhs[4]*(1)-rhs[5]*(1)-rhs[6]*(1)-rhs[7]*(1)-rhs[8]*(1)-rhs[9]*(1)-rhs[10]*(1);
}
void multbymAT(double *lhs, double *rhs) {
  lhs[0] = -rhs[0]*(-1);
  lhs[1] = -rhs[1]*(-1);
  lhs[2] = -rhs[2]*(-1);
  lhs[3] = -rhs[0]*(params.Y[0])-rhs[1]*(params.Y[1])-rhs[2]*(params.Y[2])-rhs[3]*(1);
  lhs[4] = -rhs[0]*(params.Y[3])-rhs[1]*(params.Y[4])-rhs[2]*(params.Y[5])-rhs[3]*(1);
  lhs[5] = -rhs[0]*(params.Y[6])-rhs[1]*(params.Y[7])-rhs[2]*(params.Y[8])-rhs[3]*(1);
  lhs[6] = -rhs[0]*(params.Y[9])-rhs[1]*(params.Y[10])-rhs[2]*(params.Y[11])-rhs[3]*(1);
  lhs[7] = -rhs[0]*(params.Y[12])-rhs[1]*(params.Y[13])-rhs[2]*(params.Y[14])-rhs[3]*(1);
  lhs[8] = -rhs[0]*(params.Y[15])-rhs[1]*(params.Y[16])-rhs[2]*(params.Y[17])-rhs[3]*(1);
  lhs[9] = -rhs[0]*(params.Y[18])-rhs[1]*(params.Y[19])-rhs[2]*(params.Y[20])-rhs[3]*(1);
  lhs[10] = -rhs[0]*(params.Y[21])-rhs[1]*(params.Y[22])-rhs[2]*(params.Y[23])-rhs[3]*(1);
}
void multbymG(double *lhs, double *rhs) {
  lhs[0] = -rhs[3]*(-1);
  lhs[1] = -rhs[4]*(-1);
  lhs[2] = -rhs[5]*(-1);
  lhs[3] = -rhs[6]*(-1);
  lhs[4] = -rhs[7]*(-1);
  lhs[5] = -rhs[8]*(-1);
  lhs[6] = -rhs[9]*(-1);
  lhs[7] = -rhs[10]*(-1);
}
void multbymGT(double *lhs, double *rhs) {
  lhs[0] = 0;
  lhs[1] = 0;
  lhs[2] = 0;
  lhs[3] = -rhs[0]*(-1);
  lhs[4] = -rhs[1]*(-1);
  lhs[5] = -rhs[2]*(-1);
  lhs[6] = -rhs[3]*(-1);
  lhs[7] = -rhs[4]*(-1);
  lhs[8] = -rhs[5]*(-1);
  lhs[9] = -rhs[6]*(-1);
  lhs[10] = -rhs[7]*(-1);
}
void multbyP(double *lhs, double *rhs) {
  /* TODO use the fact that P is symmetric? */
  /* TODO check doubling / half factor etc. */
  lhs[0] = rhs[0]*(2);
  lhs[1] = rhs[1]*(2);
  lhs[2] = rhs[2]*(2);
  lhs[3] = 0;
  lhs[4] = 0;
  lhs[5] = 0;
  lhs[6] = 0;
  lhs[7] = 0;
  lhs[8] = 0;
  lhs[9] = 0;
  lhs[10] = 0;
}
void fillq(void) {
  work.q[0] = 0;
  work.q[1] = 0;
  work.q[2] = 0;
  work.q[3] = 0;
  work.q[4] = 0;
  work.q[5] = 0;
  work.q[6] = 0;
  work.q[7] = 0;
  work.q[8] = 0;
  work.q[9] = 0;
  work.q[10] = 0;
}
void fillh(void) {
  work.h[0] = 0;
  work.h[1] = 0;
  work.h[2] = 0;
  work.h[3] = 0;
  work.h[4] = 0;
  work.h[5] = 0;
  work.h[6] = 0;
  work.h[7] = 0;
}
void fillb(void) {
  work.b[0] = 0;
  work.b[1] = 0;
  work.b[2] = 0;
  work.b[3] = 1;
}
void pre_ops(void) {
}
