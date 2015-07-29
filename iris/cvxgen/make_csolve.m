% Produced by CVXGEN, 2014-05-20 16:06:21 -0400.
% CVXGEN is Copyright (C) 2006-2012 Jacob Mattingley, jem@cvxgen.com.
% The code in this file is Copyright (C) 2006-2012 Jacob Mattingley.
% CVXGEN, or solvers produced by CVXGEN, cannot be used for commercial
% applications without prior written permission from Jacob Mattingley.

% Filename: make_csolve.m.
% Description: Calls mex to generate the cvxgen_ldp_mex mex file.
%mex -v cvxgen_ldp_mex.c ldl.c matrix_support.c solver.c util.c
mex cvxgen_ldp_mex.c ldl.c matrix_support.c solver.c util.c
