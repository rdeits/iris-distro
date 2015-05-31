#include <assert.h>
#include <math.h>
#include <stdio.h>
#include "iris.h"

void test_append_polytope() {
  Polytope* polytope = construct_polytope(3, 2);
  polytope->A[0][0] = -1;
  polytope->A[0][1] = 0;
  polytope->A[1][0] = 0;
  polytope->A[1][1] = -1;
  polytope->A[2][0] = 1;
  polytope->A[2][1] = 1;
  polytope->b[0] = 0;
  polytope->b[1] = 0;
  polytope->b[2] = 1;

  Polytope* other = construct_polytope(2, 2);
  other->A[0][0] = 2;
  other->A[0][1] = 3;
  other->A[1][0] = 4;
  other->A[1][1] = 5;
  other->b[0] = 6;
  other->b[1] = 7;

  append_polytope(polytope, other);
  assert(polytope->m == 5);
  assert(polytope->A[0][0] == -1);
  assert(polytope->A[2][1] == 1);
  assert(polytope->b[2] == 1);
  assert(polytope->A[3][0] == 2);
  assert(polytope->A[4][0] == 4);
  assert(polytope->A[4][1] == 5);
  assert(polytope->b[4] == 7);
  printf("test_append_polytope passed\n");
}

void test_mosek_ellipsoid() {
  int nrows = 3;
  int dim = 2;
  Polytope* polytope = construct_polytope(nrows, dim);
  Ellipsoid* ellipsoid = construct_ellipsoid(dim);

  polytope->A[0][0] = -1;
  polytope->A[0][1] = 0;
  polytope->A[1][0] = 0;
  polytope->A[1][1] = -1;
  polytope->A[2][0] = 1;
  polytope->A[2][1] = 1;
  polytope->b[0] = 0;
  polytope->b[1] = 0;
  polytope->b[2] = 1;

  double volume;
  inner_ellipsoid(polytope, ellipsoid, &volume);

  assert(abs(ellipsoid->C[0][0] - 0.332799) < 1e-5);
  assert(abs(ellipsoid->C[0][1] - -0.132021) < 1e-5);
  assert(abs(ellipsoid->C[1][1] - 0.332799) < 1e-5);
  assert(abs(ellipsoid->C[1][0] - -0.132021) < 1e-5);
  assert(abs(ellipsoid->d[0] - 0.358029) < 1e-5);
  assert(abs(ellipsoid->d[1] - 0.358029) < 1e-5);

  free_ellipsoid(ellipsoid);
  free_polytope(polytope);
  printf("test_mosek_ellipsoid passed\n");
}

int main() {
  test_append_polytope();
  test_mosek_ellipsoid();
  return 0;
}
