#include <stdexcept>
#include <setoper.h>
#include <cdd.h>

using namespace Eigen;

namespace {
  struct cdd_global_constants_initializer {
    cdd_global_constants_initializer() {
      dd_set_global_constants();
      std::cout << "Loading cdd global constants" << std::endl;
    }
    ~cdd_global_constants_initializer() {
      std::cout << "Freeing cdd global constants" << std::endl;
      dd_free_global_constants();
    }
  };
  static cdd_global_constants_initializer cdd_init;
}

void dd_check(dd_ErrorType err) {
  if (err != dd_NoError) {
    throw std::runtime_error("dd error");
  }
}

namespace iris {

void getGenerators(const MatrixXd &A, const VectorXd &b, std::vector<VectorXd> &points, std::vector<VectorXd> &rays) {
  assert(A.rows() == b.rows());
  int dim = A.cols();
  dd_MatrixPtr hrep = dd_CreateMatrix(A.rows(), 1 + dim);
  for (int i=0; i < A.rows(); i++) {
    dd_set_d(hrep->matrix[i][0], b(i));
    for (int j=0; j < dim; j++) {
      dd_set_d(hrep->matrix[i][j+1], -A(i,j));
    }
  }
  hrep->representation = dd_Inequality;
  dd_ErrorType err;
  dd_PolyhedraPtr poly = dd_DDMatrix2Poly(hrep, &err);
  dd_check(err);

  dd_MatrixPtr generators = dd_CopyGenerators(poly);
  // dd_WriteMatrix(stdout, generators);

  // std::cout << "rowsize: " << generators->rowsize << " colsize: " << generators->colsize << std::endl;
  assert(dim + 1 == generators->colsize);
  for (int i=0; i < generators->rowsize; i++) {
    VectorXd point_or_ray(dim);
    for (int j=0; j < dim; j++) {
      point_or_ray(j) = dd_get_d(generators->matrix[i][j+1]);
    }
    if (dd_get_d(generators->matrix[i][0]) == 0) {
      rays.push_back(point_or_ray);
    } else {
      points.push_back(point_or_ray);
    }
  }

  dd_FreeMatrix(hrep);
  dd_FreeMatrix(generators);
  dd_FreePolyhedra(poly);
}

}