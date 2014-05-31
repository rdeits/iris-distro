/* 
   Copyright: Copyright (c) MOSEK ApS, Denmark. All rights reserved.

   File:      sdo1.c

   Purpose:   Solves the following small semidefinite optimization problem 
              using the MOSEK API.

     minimize    Tr [2, 1, 0; 1, 2, 1; 0, 1, 2]*X + x0
 
     subject to  Tr [1, 0, 0; 0, 1, 0; 0, 0, 1]*X + x0           = 1
                 Tr [1, 1, 1; 1, 1, 1; 1, 1, 1]*X      + x1 + x2 = 0.5
                 (x0,x1,x2) \in Q,  X \in PSD
*/


#include <stdio.h>

#include "mosek.h"    /* Include the MOSEK definition file.  */

#define NUMCON    2   /* Number of constraints.              */
#define NUMVAR    3   /* Number of conic quadratic variables */
#define NUMANZ    3   /* Number of non-zeros in A            */
#define NUMBARVAR 1   /* Number of semidefinite variables    */

static void MSKAPI printstr(void *handle,
                            MSKCONST char str[])
{
  printf("%s",str);
} /* printstr */

int main(int argc,char *argv[])
{
  MSKrescodee  r;
  
  MSKint32t    DIMBARVAR[] = {3};         /* Dimension of semidefinite cone */
  MSKint64t    LENBARVAR[] = {3*(3+1)/2}; /* Number of scalar SD variables  */
  
  MSKboundkeye bkc[] = { MSK_BK_FX, MSK_BK_FX };
  double       blc[] = { 1.0, 0.5 };
  double       buc[] = { 1.0, 0.5 };
   
  MSKint32t    barc_i[] = {0, 1, 1, 2, 2},
               barc_j[] = {0, 0, 1, 1, 2};
  double       barc_v[] = {2.0, 1.0, 2.0, 1.0, 2.0};

  MSKint32t    aptrb[]  = {0, 1},
               aptre[]  = {1, 3},
               asub[]   = {0, 1, 2}; /* column subscripts of A */
  double       aval[]   = {1.0, 1.0, 1.0};

  MSKint32t    bara_i[] = {0, 1, 2, 0, 1, 2, 1, 2, 2},
               bara_j[] = {0, 1, 2, 0, 0, 0, 1, 1, 2};
  double       bara_v[] = {1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0};
  MSKint32t    conesub[] = {0, 1, 2};

  MSKint32t    i,j;
  MSKint64t    idx;
  double       falpha = 1.0;

  double       *xx;
  double       *barx;
  MSKenv_t     env = NULL;
  MSKtask_t    task = NULL;

  /* Create the mosek environment. */
  r = MSK_makeenv(&env,NULL);

  if ( r==MSK_RES_OK )
  {
    /* Create the optimization task. */
    r = MSK_maketask(env,NUMCON,0,&task);

    if ( r==MSK_RES_OK )
    {
      MSK_linkfunctotaskstream(task,MSK_STREAM_LOG,NULL,printstr);
       
      /* Append 'NUMCON' empty constraints.
       The constraints will initially have no bounds. */
      if ( r == MSK_RES_OK )
        r = MSK_appendcons(task,NUMCON);

      /* Append 'NUMVAR' variables.
     The variables will initially be fixed at zero (x=0). */
      if ( r == MSK_RES_OK )
        r = MSK_appendvars(task,NUMVAR);

      /* Append 'NUMBARVAR' semidefinite variables. */
      if ( r == MSK_RES_OK ) {
        r = MSK_appendbarvars(task, NUMBARVAR, DIMBARVAR);
      }

      /* Optionally add a constant term to the objective. */
      if ( r ==MSK_RES_OK )
        r = MSK_putcfix(task,0.0);

      /* Set the linear term c_j in the objective.*/
      if ( r ==MSK_RES_OK )
        r = MSK_putcj(task,0,1.0);

      for (j=0; j<NUMVAR && r==MSK_RES_OK; ++j)
        r = MSK_putvarbound( task,
                             j,
                             MSK_BK_FR,
                             -MSK_INFINITY,
                             MSK_INFINITY);

      /* Set the linear term barc_j in the objective.*/  
      if ( r == MSK_RES_OK )
        r = MSK_appendsparsesymmat(task,
                                   DIMBARVAR[0],
                                   5,
                                   barc_i,
                                   barc_j,
                                   barc_v,
                                   &idx);

      if ( r == MSK_RES_OK )
        r = MSK_putbarcj(task, 0, 1, &idx, &falpha);

      /* Set the bounds on constraints.
        for i=1, ...,NUMCON : blc[i] <= constraint i <= buc[i] */
      for(i=0; i<NUMCON && r==MSK_RES_OK; ++i)
        r = MSK_putconbound(task,
                           i,           /* Index of constraint.*/
                           bkc[i],      /* Bound key.*/
                           blc[i],      /* Numerical value of lower bound.*/
                           buc[i]);     /* Numerical value of upper bound.*/

      /* Input A row by row */
      for (i=0; i<NUMCON && r==MSK_RES_OK; ++i)
        r = MSK_putarow(task,
                        i,
                        aptre[i] - aptrb[i],
                        asub     + aptrb[i],
                        aval     + aptrb[i]);

      /* Append the conic quadratic cone */
      if ( r==MSK_RES_OK )
        r = MSK_appendcone(task,
                           MSK_CT_QUAD,
                           0.0,
                           3,
                           conesub);

      /* Add the first row of barA */
      if ( r==MSK_RES_OK )
        r = MSK_appendsparsesymmat(task,
                              DIMBARVAR[0],
                              3,
                              bara_i,
                              bara_j,
                              bara_v,
                              &idx);

      if ( r==MSK_RES_OK )
        r = MSK_putbaraij(task, 0, 0, 1, &idx, &falpha);
	
      /* Add the second row of barA */
      if ( r==MSK_RES_OK )
        r = MSK_appendsparsesymmat(task,
			                  DIMBARVAR[0],
			                  6,
			                  bara_i + 3,
			                  bara_j + 3,
			                  bara_v + 3,
			                  &idx);

      if ( r==MSK_RES_OK )
        r = MSK_putbaraij(task, 1, 0, 1, &idx, &falpha);

      if ( r==MSK_RES_OK )
      {
        MSKrescodee trmcode;
        
        /* Run optimizer */
        r = MSK_optimizetrm(task,&trmcode);

        /* Print a summary containing information
           about the solution for debugging purposes*/
        MSK_solutionsummary (task,MSK_STREAM_MSG);
        
        if ( r==MSK_RES_OK )
        {
          MSKsolstae solsta;
          
          MSK_getsolsta (task,MSK_SOL_ITR,&solsta);
          
          switch(solsta)
          {
            case MSK_SOL_STA_OPTIMAL:
            case MSK_SOL_STA_NEAR_OPTIMAL:
              xx   = (double*) MSK_calloctask(task,NUMVAR,sizeof(MSKrealt));
              barx = (double*) MSK_calloctask(task,LENBARVAR[0],sizeof(MSKrealt));

              MSK_getxx(task,
                        MSK_SOL_ITR,
                        xx);
              MSK_getbarxj(task,
                           MSK_SOL_ITR,    /* Request the interior solution. */
                           0,
                           barx);
              
              printf("Optimal primal solution\n");
              for(i=0; i<NUMVAR; ++i)
                printf("x[%d]   : % e\n",i,xx[i]);

              for(i=0; i<LENBARVAR[0]; ++i)
                printf("barx[%d]: % e\n",i,barx[i]);
              
              MSK_freetask(task,xx);
              MSK_freetask(task,barx);

              break;
            case MSK_SOL_STA_DUAL_INFEAS_CER:
            case MSK_SOL_STA_PRIM_INFEAS_CER:
            case MSK_SOL_STA_NEAR_DUAL_INFEAS_CER:
            case MSK_SOL_STA_NEAR_PRIM_INFEAS_CER:  
              printf("Primal or dual infeasibility certificate found.\n");
              break;
              
            case MSK_SOL_STA_UNKNOWN:
              printf("The status of the solution could not be determined.\n");
              break;
            default:
              printf("Other solution status.");
              break;
          }
        }
        else
        {
          printf("Error while optimizing.\n");
        }
      }
    
      if (r != MSK_RES_OK)
      {
        /* In case of an error print error code and description. */      
        char symname[MSK_MAX_STR_LEN];
        char desc[MSK_MAX_STR_LEN];
        
        printf("An error occurred while optimizing.\n");     
        MSK_getcodedesc (r,
                         symname,
                         desc);
        printf("Error %s - '%s'\n",symname,desc);
      }
    }
    /* Delete the task and the associated data. */
    MSK_deletetask(&task);
  }
 
  /* Delete the environment and the associated data. */
  MSK_deleteenv(&env);

  return ( r );
} /* main */
