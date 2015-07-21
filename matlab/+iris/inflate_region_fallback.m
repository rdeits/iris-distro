function [A, b, C, d, results] = inflate_region_fallback(obstacles, A_bounds, b_bounds, start, options)
% MATLAB-only implementation of IRIS. This is slower and less flexible than the c++ interface, but does not require any compilation.  
import iris.*;

DEBUG = false;

if ~exist('mosekopt', 'file')
  addpath_mosek
end

results = inflation_results();
results.start = start;
if iscell(obstacles)
  results.obstacles = obstacles;
else
  results.obstacles = mat2cell(obstacles, size(obstacles, 1), size(obstacles, 2), ones(1, size(obstacles, 3)));
end
results.n_obs = numel(results.obstacles);

if iscell(obstacles)
  padded = pad_obstacle_points(obstacles);
  obstacle_pts = cell2mat(reshape(padded, size(padded, 1), [], length(obstacles)));
else
  obstacle_pts = obstacles;
end

t0 = tic;

dim = size(A_bounds, 2);
d = start;
C = 0.01 * eye(dim);
best_vol = -inf;
iter = 1;
results.e_history{1} = struct('C', C, 'd', d);

while true
  tic
  [A, b, infeas_start] = separating_hyperplanes(obstacle_pts, C, d);
  if options.error_on_infeasible_start && infeas_start
    error('IRIS:InfeasibleStart', 'ellipse center is inside an obstacle');
  end
  results.p_time = results.p_time + toc;
  if iter > 1 && DEBUG
    for i = 1:length(b)
      assert(min(eig([(b(i) - A(i,:) * d) * eye(dim), C * (A(i,:)');
         (C * (A(i,:)'))', (b(i) - A(i,:) * d)])) >= -1e-3);
    end
  end
  A = [A; A_bounds];
  b = [b; b_bounds];

  if options.require_containment
    if all(A * start <= b) || iter == 1 || infeas_start
      results.p_history{iter} = struct('A', A, 'b', b);
    else
      hist = results.p_history{iter-1};
      A = hist.A;
      b = hist.b;
      disp('Breaking early because start point is no longer contained in polyhedron');
      break
    end
  else
    results.p_history{iter} = struct('A', A, 'b', b);
  end

  tic
  [C, d, cvx_optval] = maximal_ellipse(A,b);
  results.e_time = results.e_time + toc;
  results.e_history{iter+1} = struct('C', C, 'd', d);

  if abs(cvx_optval - best_vol)/best_vol < 2e-2
    break
  end
  best_vol = cvx_optval;
  iter = iter + 1;
end

results.iters = iter;
results.total_time = toc(t0);