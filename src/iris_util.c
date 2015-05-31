#include "iris_util.h"

#include <assert.h>
#include <string.h>
#include <stdio.h>

Matrix* construct_matrix(int rows, int cols) {
  Matrix* matrix = malloc(sizeof(Matrix));
  matrix->data = malloc(rows * cols * sizeof(double));
  matrix->rows = rows;
  matrix->cols = cols;
  return matrix;
}

void copy_matrix(Matrix* source, Matrix* destination) {
  assert(source->rows == destination->rows);
  assert(source->cols == destination->cols);
  assert(destination->data);
  assert(source->data);
  for (int i=0; i < source->rows; i++) {
    for (int j=0; j < source->cols; j++) {
      *index(destination, i, j) = *index(source, i, j);
    }
  }
}

void free_matrix(Matrix* matrix) {
  free(matrix->data);
  free(matrix);
}

void set_matrix_data(Matrix* matrix, int cols, double data[][cols]) {
  assert(matrix->cols == cols);
  for (int i=0; i < matrix->rows; i++) {
    for (int j=0; j < matrix->cols; j++) {
      *index(matrix, i, j) = data[i][j];
    }
  }
}

double* index(Matrix* matrix, size_t row, size_t col) {
  // printf("indexing: %d, %d -> %d\n", row, col, row + col * matrix->rows);
  return matrix->data + row + col * matrix->rows;
}

// LU decomoposition of a general matrix
void dgetrf_(int* M, int *N, double* A, int* lda, int* ipiv, int* info);

// generate inverse of a matrix given its LU decomposition
void dgetri_(int* N, double* A, int* lda, int* ipiv, double* work, int* lwork, int* info);

Matrix* invert_matrix(Matrix* matrix) {
  assert(matrix->rows == matrix->cols);
  Matrix* inv = construct_matrix(matrix->rows, matrix->cols);
  copy_matrix(matrix, inv);

  int ipiv[matrix->rows];
  int lwork = matrix->rows * matrix->rows;
  double work[matrix->rows * matrix->rows];
  int info;
  int dim = matrix->rows;
  dgetrf_(&dim, &dim, inv->data, &dim, ipiv, &info);
  dgetri_(&dim, inv->data, &dim, ipiv, &work, &lwork, &info);
  return inv;
}

Polytope* construct_polytope(int m, int n) {
  Polytope* polytope = malloc(sizeof(Polytope));
  polytope->num_faces = m;
  polytope->dim = n;
  polytope->A = construct_matrix(m, n);
  polytope->b = construct_matrix(m, 1);
  return polytope;
}

Matrix* vstack(Matrix* this, Matrix* other) {
  assert(this->cols == other->cols);
  Matrix* res = construct_matrix(this->rows + other->rows, this->cols);
  for (int i=0; i < this->rows; i++) {
    for (int j=0; j < this->cols; j++) {
      *index(res, i, j) = *index(this, i, j);
    }
  }
  for (int i=0; i < other->rows; i++) {
    for (int j=0; j < this->cols; j++) {
      *index(res, i + this->rows, j) = *index(other, i, j);
    }
  }
  return res;
}

void append_polytope(Polytope* this, Polytope *other) {
  // Modify this in place by adding the rows from other
  assert(this->dim == other->dim);
  Matrix* this_A_old = this->A;
  this->A = vstack(this->A, other->A);
  free_matrix(this_A_old);

  Matrix* this_b_old = this->b;
  this->b = vstack(this->b, other->b);
  free_matrix(this_b_old);

  this->num_faces += other->num_faces;
}

void print_matrix(Matrix* matrix) {
  for (int i=0; i < matrix->rows; i++) {
    for (int j=0; j < matrix->cols; j++) {
      printf("%f ", *index(matrix, i, j));
    }
    printf("\n");
  }
}

void free_polytope(Polytope* polytope) {
  free_matrix(polytope->A);
  free_matrix(polytope->b);
  free(polytope);
}

Ellipsoid* construct_ellipsoid(int dim) {
  Ellipsoid* ellipsoid = malloc(sizeof(Ellipsoid));
  ellipsoid->dim = dim;
  ellipsoid->C = construct_matrix(dim, dim);
  ellipsoid->d = construct_matrix(dim, 1);
  return ellipsoid;
}

void free_ellipsoid(Ellipsoid* ellipsoid) {
  free_matrix(ellipsoid->C);
  free_matrix(ellipsoid->d);
  free(ellipsoid);
}