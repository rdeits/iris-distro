#include <iostream>
#include <cmath>
#include <map>
#include <Eigen/Core>

#include "mosek.h"

#define DEBUG false

using namespace Eigen;

int inner_ellipsoid(MatrixXd A, VectorXd b, MatrixXd C, VectorXd d) {
  int m = A.rows();
  int n = A.cols();

  int l = std::ceil(std::log2(n));


  std::map<std::string, int> num;
  num["t"] = 1;
  num["d"] = n;
  num["s"] = std::pow(2, l) - 1;
  num["sprime"] = num["s"];
  num["z"] = std::pow(2, l);
  num["f"] = m * n;
  num["g"] = m;

  std::map<std::string, VectorXi> ndx;
  int nvar = 0;
  std::vector<std::string> var_names = {"t", "d", "s", "sprime", "z", "f", "g"};
  for (auto var = var_names.begin(); var != var_names.end(); ++var) {
    ndx[*var] = VectorXi::LinSpaced(Sequential,num[*var],1,num[*var]).array() + nvar;
    nvar += num[*var];
  }

  int ncon = n * m + m + n + n + (std::pow(2, l) - n) + 1 + (n * (n-1) / 2) + (std::pow(2, l) - 1);

}