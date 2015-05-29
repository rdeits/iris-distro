#include <stdio.h>
#include <math.h>

#include "mosek.h"

#define DEBUG false

#define ADD_VAR(x) int* ndx_##x = (int*) malloc(sizeof(int) * num_##x); for (int i=0; i < num_##x; i++) ndx_##x[i] = nvar++;
#define FREE_VAR(x) free(ndx_##x);

int inner_ellipsoid(const double** A, const double* b, int m, int dim, double** C, double* d) {

  const int n = dim;
  const int l = ceil(log2(n));

  const int num_t = 1;
  const int num_d = n;
  const int num_s = pow(2, l) - 1;
  const int num_sprime = num_s;
  const int num_z = pow(2, l);
  const int num_f = m * n;
  const int num_g = m;

  int nvar = 0;
  ADD_VAR(t)
  ADD_VAR(d)
  ADD_VAR(s)
  ADD_VAR(sprime)
  ADD_VAR(z)
  ADD_VAR(f)
  ADD_VAR(g)

  const int ncon = n * m + m + n + n + (pow(2, l) - n) + 1 + (n * (n-1) / 2) + (pow(2, l) - 1);

  const int nabar = n * m * n + n + n + (n * (n-1) / 2);
  int abar_ndx = 0;

  MSKenv_t env = NULL;
  MSKtask_t task = NULL;
  MSKrescodee res;

  res = MSK_makeenv(&env, NULL);
  if (res == MSK_RES_OK)
    res = MSK_maketask(env, ncon, 0, &task);

  if (res == MSK_RES_OK)
    res = MSK_appendcons(task, ncon);

  if (res == MSK_RES_OK)
    res = MSK_appendvars(task, nvar);

  MSKint32t dim_bar[] = {2*n};
  if (res == MSK_RES_OK)
    res = MSK_appendbarvars(task, 1, dim_bar);

  if (res == MSK_RES_OK)
    res = MSK_putcj(task, ndx_t[0], 1.0);

  for (int i=0; i < nvar && res == MSK_RES_OK; i++) {
    res = MSK_putvarbound(task, i, MSK_BK_FR, -MSK_INFINITY, MSK_INFINITY);
  }

  int* bara_i = (int*) malloc(nabar * sizeof(int));
  int* bara_j = (int*) malloc(nabar * sizeof(int));
  int* bara_k = (int*) malloc(nabar * sizeof(int));
  int* bara_l = (int*) malloc(nabar * sizeof(int));
  int* bara_v = (int*) malloc(nabar * sizeof(int));

  int con_ndx = 0;
  for (int i=0; i < m; i++) {
    // a_i^T C = [f_{i,1}, f_{i,2}, ..., f_{i,n}]
    for (int j=0; j < n; j++) {
      for (int k=0; k < n; k++) {
        bara_i[abar_ndx + k] = con_ndx;
        bara_j[abar_ndx + k] = 1;
        if (j >= k) {
          bara_k[abar_ndx + k] = j;
          bara_l[abar_ndx + k] = k;
        } else {
          bara_k[abar_ndx + k] = k;
          bara_k[abar_ndx + k] = j;
        }
      }
      abar_ndx += n;
      MSKint32t subi[] = {ndx_f[i + m * j]};
      MSKrealt vali[] = {-1};
      if (res == MSK_RES_OK)
        res = MSK_putarow(task, con_ndx, 1, subi, vali);
      if (res == MSK_RES_OK)
        res = MSK_putconbound(task, con_ndx, MSK_BK_FX, 0, 0);
    }
  }

  free(bara_i);
  free(bara_j);
  free(bara_k);
  free(bara_l);
  free(bara_v);
  FREE_VAR(t)
  FREE_VAR(d)
  FREE_VAR(s)
  FREE_VAR(sprime)
  FREE_VAR(z)
  FREE_VAR(f)
  FREE_VAR(g)

  MSK_deletetask(&task);
  MSK_deleteenv(&env);


  // std::map<std::string, VectorXi> ndx;
  // int nvar = 0;
  // std::vector<std::string> var_names = {"t", "d", "s", "sprime", "z", "f", "g"};
  // for (auto var = var_names.begin(); var != var_names.end(); ++var) {
  //   ndx[*var] = VectorXi::LinSpaced(Sequential,num[*var],1,num[*var]).array() + nvar;
  //   nvar += num[*var];
  // }

  // int ncon = n * m + m + n + n + (std::pow(2, l) - n) + 1 + (n * (n-1) / 2) + (std::pow(2, l) - 1);

  // int nabar = n * m * n + n + n + (n * (n-1) / 2);
  // ab

  return res;

}

int main() {
  int res = inner_ellipsoid(NULL, NULL, 3, 3, NULL, NULL);
  printf("%d\n", res);
}