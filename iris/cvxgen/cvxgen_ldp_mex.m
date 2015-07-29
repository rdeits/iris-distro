% cvxgen_ldp_mex  Solves a custom quadratic program very rapidly.
%
% [vars, status] = cvxgen_ldp_mex(params, settings)
%
% solves the convex optimization problem
%
%   minimize(sum(square(v)))
%   subject to
%     Y*w == v
%     sum(w) == 1
%
% with variables
%        v   3 x 1
%        w   8 x 1    positive
%
% and parameters
%        Y   3 x 8
%
% Note:
%   - Check status.converged, which will be 1 if optimization succeeded.
%   - You don't have to specify settings if you don't want to.
%   - To hide output, use settings.verbose = 0.
%   - To change iterations, use settings.max_iters = 20.
%   - You may wish to compare with cvxsolve to check the solver is correct.
%
% Specify params.Y, ..., params.Y, then run
%   [vars, status] = cvxgen_ldp_mex(params, settings)
% Produced by CVXGEN, 2014-05-20 16:06:21 -0400.
% CVXGEN is Copyright (C) 2006-2012 Jacob Mattingley, jem@cvxgen.com.
% The code in this file is Copyright (C) 2006-2012 Jacob Mattingley.
% CVXGEN, or solvers produced by CVXGEN, cannot be used for commercial
% applications without prior written permission from Jacob Mattingley.

% Filename: cvxgen_ldp_mex.m.
% Description: Help file for the Matlab solver interface.
