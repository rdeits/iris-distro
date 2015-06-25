#include <assert.h>
// #include <math.h>
// #include <stdio.h>
// #include <stdlib.h>
// #include <string.h>
#include "iris.h"
#include "iris_mosek.h"
#include "dbg.h"

template <typename T>
void valuecheck(const T& a, const T& b)
{
  if (a != b) {
    std::ostringstream stream;
    stream << "Expected:\n" << a << "\nbut got:" << b << "\n";
    throw std::runtime_error(stream.str());
  }
}


void test_append_polytope() {
  Polytope* polytope = construct_polytope(3, 2);
  double A[3][2] = {{-1, 0},
                    {0, -1},
                    {1, 1}};
  set_matrix_data(polytope->A, 2, A);
  double b[3][1] = {0, 0, 1};
  set_matrix_data(polytope->b, 1, b);

  Polytope* other = construct_polytope(2, 2);
  double A2[2][2] = {{2, 3},
                     {4, 5}};
  set_matrix_data(other->A, 2, A2);
  double b2[2][1] = {6, 7};
  set_matrix_data(other->b, 1, b2);

  append_polytope(polytope, other);

  assert(polytope->num_faces == 5);
  assert(*index(polytope->A, 0, 0) == -1);
  assert(*index(polytope->A, 2, 1) == 1);
  assert(*index(polytope->b, 2, 0) == 1);
  assert(*index(polytope->A, 3, 0) == 2);
  assert(*index(polytope->A, 4, 0) == 4);
  assert(*index(polytope->A, 4, 1) == 5);
  assert(*index(polytope->b, 4, 0) == 7);
  printf("test_append_polytope passed\n");
}

void test_mosek_ellipsoid() {
  int nrows = 3;
  int dim = 2;
  Polytope* polytope = construct_polytope(nrows, dim);
  Ellipsoid* ellipsoid = construct_ellipsoid(dim);

  double A[3][2] = {{-1, 0},
                    {0, -1},
                    {1, 1}};
  set_matrix_data(polytope->A, 2, A);
  double b[3][1] = {0, 0, 1};
  set_matrix_data(polytope->b, 1, b);

  double volume;
  inner_ellipsoid(polytope, ellipsoid, &volume);

  assert(abs(*index(ellipsoid->C, 0, 0) - 0.332799) < 1e-5);
  assert(abs(*index(ellipsoid->C, 0, 1) - -0.132021) < 1e-5);
  assert(abs(*index(ellipsoid->C, 1, 1) - 0.332799) < 1e-5);
  assert(abs(*index(ellipsoid->C, 1, 0) - -0.132021) < 1e-5);
  assert(abs(*index(ellipsoid->d, 0, 0) - 0.358029) < 1e-5);
  assert(abs(*index(ellipsoid->d, 1, 0) - 0.358029) < 1e-5);

  free_ellipsoid(ellipsoid);
  free_polytope(polytope);
  printf("test_mosek_ellipsoid passed\n");
}

void test_infeasible_ellipsoid() {
  int nrows = 3;
  int dim = 2;
  Polytope* polytope = construct_polytope(nrows, dim);
  Ellipsoid* ellipsoid = construct_ellipsoid(dim);

  double A[3][2] = {{-1, 0},
                    {0, -1},
                    {1, 1}};
  set_matrix_data(polytope->A, 2, A);
  double b[3][1] = {0, 0, -1};
  set_matrix_data(polytope->b, 1, b);

  double volume;
  int err = inner_ellipsoid(polytope, ellipsoid, &volume);
  check(err, "expected an error code");

  printf("test_infeasble_ellipsoid passed\n");
  return;

error:
  return;

}

void test_inverse() {
  double M_orig[3][3] = {{8, 1, 6},
                    {3, 5, 7},
                    {4, 9, 2}};
  double Minv_expected[3][3] = {{0.1472, -0.1444, 0.0639},
                                {-0.0611, 0.0222, 0.1056},
                                {-0.0194, 0.1889, -0.1028}};
  Matrix *M = construct_matrix(3, 3);
  set_matrix_data(M, 3, M_orig);
  Matrix *Minv = invert_matrix(M);
  for (int i=0; i < 3; i++) {
    for (int j=0; j < 3; j++) {
      assert(abs(*index(Minv, i, j) - Minv_expected[i][j]) < 1e-3);
    }
  } 
  printf("test_inverse passed\n");
}

void test_product() {
  double A_data[2][2] = {{1, 0},
                         {0, 1}};
  Matrix *A = construct_matrix(2, 2);
  set_matrix_data(A, 2, A_data);

  double B_data[2][2] = {{3, 2},
                         {7, 9}};
  Matrix *B = construct_matrix(2, 2);
  set_matrix_data(B, 2, B_data);

  Matrix *C = construct_matrix(2, 2);
  matrix_product(A, B, C);

  double C_expected_data[2][2] = {{3, 2},
                                  {7, 9}};
  Matrix *C_expected = construct_matrix(2, 2);
  set_matrix_data(C_expected, 2, C_expected_data);

  for (int i=0; i < 2; i++) {
    for (int j=0; j < 2; j++) {
      printf("got: %f, expected: %f\n", *index(C, i, j), *index(C_expected, i, j));
      assert(abs(*index(C, i, j) - *index(C_expected, i, j)) < 1e-12);
    }
  }
  printf("test_product passed");
}

int main() {
  test_append_polytope();
  test_mosek_ellipsoid();
  test_infeasible_ellipsoid();
  test_inverse();
  test_product();
  return 0;
}
