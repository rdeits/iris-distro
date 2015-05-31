#include "iris_mosek.h"
// #define DEBUG

#include <stdio.h>
#include <stdbool.h>
#include <math.h>

#ifdef DEBUG
  #include <assert.h>
#endif

#include "mosek.h"

#define ADD_VAR(x) int* ndx_##x = (int*) malloc(sizeof(int) * num_##x); for (int i=0; i < num_##x; i++) ndx_##x[i] = nvar++;
#define FREE_VAR(x) free(ndx_##x);

/* This function prints log output from MOSEK to the terminal. */ 
static void MSKAPI printstr(void *handle, 
                            MSKCONST char str[]) 
{ 
  printf("%s",str); 
} /* printstr */ 

int inner_ellipsoid(Polytope* polytope, Ellipsoid* ellipsoid, double* volume) {

  const int m = polytope->num_faces;
  const int n = polytope->dim;
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

  #ifdef DEBUG
    /* Directs the log task stream to the 'printstr' function. */ 
    if ( res ==MSK_RES_OK ) 
      res  = MSK_linkfunctotaskstream(task,MSK_STREAM_LOG,NULL,printstr); 
  #endif

  if (res == MSK_RES_OK)
    res = MSK_appendcons(task, ncon);

  if (res == MSK_RES_OK)
    res = MSK_appendvars(task, nvar);

  MSKint32t dim_bar[] = {2*n};
  MSKint32t len_bar[] = {(dim_bar[0] * (dim_bar[0] + 1)) / 2};
  if (res == MSK_RES_OK)
    res = MSK_appendbarvars(task, 1, dim_bar);

  if (res == MSK_RES_OK)
    res = MSK_putcj(task, ndx_t[0], 1.0);

  for (int i=0; i < nvar && res == MSK_RES_OK; i++) {
    res = MSK_putvarbound(task, i, MSK_BK_FR, -MSK_INFINITY, MSK_INFINITY);
  }

  MSKint32t* bara_i = (MSKint32t*) malloc(nabar * sizeof(MSKint32t));
  MSKint32t* bara_j = (MSKint32t*) malloc(nabar * sizeof(MSKint32t));
  MSKint32t* bara_k = (MSKint32t*) malloc(nabar * sizeof(MSKint32t));
  MSKint32t* bara_l = (MSKint32t*) malloc(nabar * sizeof(MSKint32t));
  MSKrealt* bara_v = (MSKrealt*) malloc(nabar * sizeof(MSKrealt));

  int con_ndx = 0;
  MSKint32t* subi_A_row = (MSKint32t*) malloc((num_d + 1) * sizeof(MSKint32t));
  MSKrealt* vali_A_row = (MSKrealt*) malloc((num_d + 1) * sizeof(MSKrealt));
  for (int i=0; i < m; i++) {
    // a_i^T C = [f_{i,1}, f_{i,2}, ..., f_{i,n}]
    for (int j=0; j < n; j++) {
      // (a_i^T C)_j = f_{i,j}
      for (int k=0; k < n; k++) {
        bara_i[abar_ndx + k] = con_ndx;
        bara_j[abar_ndx + k] = 0;
        // Make sure we only set the lower-triangular part of Abar
        if (j >= k) {
          bara_k[abar_ndx + k] = j;
          bara_l[abar_ndx + k] = k;
        } else {
          bara_k[abar_ndx + k] = k;
          bara_l[abar_ndx + k] = j;
        }
        bara_v[abar_ndx + k] = *index(polytope->A, i, k);
      }
      abar_ndx += n;
      MSKint32t subi[] = {ndx_f[i + m * j]};
      MSKrealt vali[] = {-1};
      if (res == MSK_RES_OK)
        res = MSK_putarow(task, con_ndx, 1, subi, vali);
      if (res == MSK_RES_OK)
        res = MSK_putconbound(task, con_ndx, MSK_BK_FX, 0, 0);

      con_ndx++;
    }
    for (int j=0; j < num_d; j++) {
      subi_A_row[j] = ndx_d[j];
      vali_A_row[j] = *index(polytope->A, i, j);
    }
    subi_A_row[num_d] = ndx_g[i];
    vali_A_row[num_d] = 1;
    if (res == MSK_RES_OK)
      res = MSK_putarow(task, con_ndx, num_d + 1, subi_A_row, vali_A_row);
    if (res == MSK_RES_OK)
      res = MSK_putconbound(task, con_ndx, MSK_BK_FX, *index(polytope->b, i, 0), *index(polytope->b, i, 0));
    con_ndx++;
  }
  free(subi_A_row);
  free(vali_A_row);

  for (int j=0; j < n; j++) {
    // Xbar_{n+j,j} == z_j
    bara_i[abar_ndx] = con_ndx;
    bara_j[abar_ndx] = 0;
    bara_k[abar_ndx] = n + j;
    bara_l[abar_ndx] = j;
    bara_v[abar_ndx] = 1;
    abar_ndx++;

    MSKint32t subi[] = {ndx_z[j]};
    MSKrealt vali[] = {-1};
    if (res == MSK_RES_OK)
      res = MSK_putarow(task, con_ndx, 1, subi, vali);
    if (res == MSK_RES_OK)
      res = MSK_putconbound(task, con_ndx, MSK_BK_FX, 0, 0);
    con_ndx++;
  }

  for (int j=0; j < n; j++) {
    // Xbar_{n+j,n+j} == z_j
    bara_i[abar_ndx] = con_ndx;
    bara_j[abar_ndx] = 0;
    bara_k[abar_ndx] = n + j;
    bara_l[abar_ndx] = n + j;
    bara_v[abar_ndx] = 1;
    abar_ndx++;

    MSKint32t subi[] = {ndx_z[j]};
    MSKrealt vali[] = {-1};
    if (res == MSK_RES_OK)
      res = MSK_putarow(task, con_ndx, 1, subi, vali);
    if (res == MSK_RES_OK)
      res = MSK_putconbound(task, con_ndx, MSK_BK_FX, 0, 0);
    con_ndx++;
  }

  // z_j == t for j > n
  for (int j=n; j < num_z; j++) {
    MSKint32t subi[] = {ndx_z[j], ndx_t[0]};
    MSKrealt vali[] = {1, -1};
    if (res == MSK_RES_OK)
      res = MSK_putarow(task, con_ndx, 2, subi, vali);
    if (res == MSK_RES_OK)
      res = MSK_putconbound(task, con_ndx, MSK_BK_FX, 0, 0);
    con_ndx++;
  }

  // Off-diagonal elements of Y22 are 0
  for (int k=n; k < 2*n; k++) {
    for (int l=n; l < k; l++) {
      bara_i[abar_ndx] = con_ndx;
      bara_j[abar_ndx] = 0;
      bara_k[abar_ndx] = k;
      bara_l[abar_ndx] = l;
      bara_v[abar_ndx] = 1;
      abar_ndx++;

      if (res == MSK_RES_OK)
        res = MSK_putconbound(task, con_ndx, MSK_BK_FX, 0, 0);

      con_ndx++;
    }
  }

  #ifdef DEBUG
    assert(abar_ndx == nabar);
  #endif

  // 2^(l/2)t == s_{2l - 1}
  MSKint32t subi[] = {ndx_t[0], ndx_s[num_s - 1]};
  MSKrealt vali[] = {pow(2, l / 2.0), -1};
  if (res == MSK_RES_OK)
    res = MSK_putarow(task, con_ndx, 2, subi, vali);
  if (res == MSK_RES_OK)
    res = MSK_putconbound(task, con_ndx, MSK_BK_FX, 0, 0);
  con_ndx++;

  // s_j == sprime_j
  for (int j=0; j < num_s; j++) {
    MSKint32t subi[] = {ndx_s[j], ndx_sprime[j]};
    MSKrealt vali[] = {1, -1};
    if (res == MSK_RES_OK)
      res = MSK_putarow(task, con_ndx, 2, subi, vali);
    if (res == MSK_RES_OK)
      res = MSK_putconbound(task, con_ndx, MSK_BK_FX, 0, 0);
    con_ndx++;
  }

  #ifdef DEBUG
    assert(con_ndx == ncon);
  #endif

  MSKint32t csub[3];
  for (int j=0; j < num_s; j++) {
    if (j < num_z) {
      csub[0] = ndx_z[j];
    } else {
      csub[0] = ndx_sprime[j - num_z];
    }
    if (j + 1 < num_z) {
      csub[1] = ndx_z[j + 1];
    } else {
      csub[1] = ndx_sprime[j + 1 - num_z];
    }
    csub[2] = ndx_s[j];
    #ifdef DEBUG
      printf("appending rquad cone with sub: %d %d %d\n", csub[0], csub[1], csub[2]);
    #endif
    if (res == MSK_RES_OK)
      res = MSK_appendcone(task, MSK_CT_RQUAD, 0.0, 3, csub); // 3rd argument (0.0) is reserved for future use by Mosek
  }

  MSKint32t* csub_f_row = (MSKint32t*) malloc((1 + n) * sizeof(MSKint32t));
  for (int i=0; i < m; i++) {
    csub_f_row[0] = ndx_g[i];
    for (int j=0; j < n; j++) {
      csub_f_row[j + 1] = ndx_f[i + m * j];
    }
    #ifdef DEBUG
      printf("appending quad cone with sub: \n");
      for (int j=0; j < n + 1; j++) {
        printf("%d ", csub_f_row[j]);
      }
      printf("\n");
    #endif
    if (res == MSK_RES_OK)
      res = MSK_appendcone(task, MSK_CT_QUAD, 0.0, n + 1, csub_f_row); // 3rd argument (0.0) is reserved for future use by Mosek
  }
  free(csub_f_row);

  // Divide all off-diagonal entries of Abar by 2. This is necessary because Abar
  // is assumed by the solver to be a symmetric matrix, but we're only setting
  // its lower triangular part.
  for (int i=0; i < nabar; i++) {
    if (bara_k[i] != bara_l[i]) {
      bara_v[i] /= 2.0;
    }
  }

  if (res == MSK_RES_OK)
    res = MSK_putbarablocktriplet(task, nabar, bara_i, bara_j, bara_k, bara_l, bara_v);


  if (res == MSK_RES_OK)
    res = MSK_putobjsense(task, MSK_OBJECTIVE_SENSE_MAXIMIZE);
  
  #ifdef DEBUG
    for (int i=0; i < 16; i++) {
      MSKint32t nzi;
      MSK_getarownumnz(task, i, &nzi);
      MSKint32t* subi = (MSKint32t*) malloc(nzi * sizeof(MSKint32t));
      MSKrealt* vali = (MSKrealt*) malloc(nzi * sizeof(MSKrealt));
      MSK_getarow(task, i, &nzi, subi, vali);
      printf("A row %d: ", i);
      for (int j=0; j < nzi; j++) {
        printf("%d: %f, ", subi[j], vali[j]);
      }
      printf("\n");
      free(subi);
      free(vali);
    }

    MSK_printdata(task, MSK_STREAM_MSG, 0, 16, 0, nvar, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0);
    MSK_printdata(task, MSK_STREAM_MSG, 0, 16, 0, nvar, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0);
  #endif

  double* xx;
  double* barx;
  if (res == MSK_RES_OK) {
    MSKrescodee trmcode;
    res = MSK_optimizetrm(task, &trmcode);

    MSK_solutionsummary(task, MSK_STREAM_MSG);

    if (res == MSK_RES_OK) {
      MSKsolstae solsta;
      MSK_getsolsta(task, MSK_SOL_ITR, &solsta);

      switch(solsta) {
        case MSK_SOL_STA_OPTIMAL:
        case MSK_SOL_STA_NEAR_OPTIMAL:
          xx = (double*) MSK_calloctask(task, nvar, sizeof(MSKrealt));
          barx = (double*) MSK_calloctask(task, len_bar[0], sizeof(MSKrealt));

          MSK_getxx(task, MSK_SOL_ITR, xx);
          MSK_getbarxj(task, MSK_SOL_ITR, 0, barx);

          #ifdef DEBUG
            printf("Optimal primal solution\n"); 
            for(int i=0; i < nvar; ++i) 
              printf("x[%d]   : % e\n",i,xx[i]); 

            for(int i=0; i < len_bar[0]; ++i) 
              printf("barx[%d]: % e\n",i,barx[i]); 
          #endif
           
          MSK_freetask(task,xx); 
          MSK_freetask(task,barx); 
          break;
        case MSK_SOL_STA_DUAL_INFEAS_CER: 
        case MSK_SOL_STA_PRIM_INFEAS_CER: 
        case MSK_SOL_STA_NEAR_DUAL_INFEAS_CER: 
        case MSK_SOL_STA_NEAR_PRIM_INFEAS_CER:   
          printf("Primal or dual infeasibility certificate found.\n"); 
          return solsta;
          break; 
        case MSK_SOL_STA_UNKNOWN: 
          printf("The status of the solution could not be determined.\n"); 
          return solsta;
          break; 
        default: 
          printf("Other solution status."); 
          return solsta;
          break;  
      }
    } else {
      printf("Error while optimizing\n");
    }
  }

  if (res != MSK_RES_OK) {
    /* In case of an error print error code and description. */       
    char symname[MSK_MAX_STR_LEN]; 
    char desc[MSK_MAX_STR_LEN]; 
     
    printf("An error occurred while optimizing.\n");      
    MSK_getcodedesc (res, 
                     symname, 
                     desc); 
    printf("Error %s - '%s'\n",symname,desc); 
    return res;
  } 

  int bar_ndx = 0;
  for (int j=0; j < 2*n; j++) {
    for (int i=j; i < 2*n; i++) {
      if (j < n && i < n) {
        *index(ellipsoid->C, i, j) = barx[bar_ndx];
        *index(ellipsoid->C, j, i) = barx[bar_ndx]; // since barx is just the lower triangle
      }
      bar_ndx++;
    }
  }

  for (int i=0; i < num_d; i++) {
    *index(ellipsoid->d, i, 0) = xx[ndx_d[i]];
  }

  if (volume) {
    MSKrealt obj_val;
    MSK_getprimalobj(task, MSK_SOL_ITR, &obj_val);
    *volume = pow(obj_val, n);
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

  return 0;
}
