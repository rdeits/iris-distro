function [A, b, C, d, results] = inflate_region(obstacles, A_bounds, b_bounds, start, callback)
import iris.*;

require_containment = false;

results = inflation_results();
results.start = start;
results.obstacles = obstacles;
results.n_obs = length(obstacles);

t0 = cputime();
obstacles = pad_obstacle_points(obstacles);
obstacle_pts = cell2mat(obstacles);

if nargin < 5 || isempty(callback)
  callback = @callback_silent;
end

dim = size(A_bounds, 2);
d = start;
C = 0.01 * eye(dim);
best_vol = -inf;
iter = 1;
results.e_history{1} = struct('C', C, 'd', d);

while true
  tic
  [A, b, infeas_start] = compute_obstacle_planes(obstacles, obstacle_pts, C, d);
  results.p_time = results.p_time + toc;
  if iter > 1
    for i = 1:length(b)
      assert(min(eig([(b(i) - A(i,:) * d) * eye(dim), C * (A(i,:)');
         (C * (A(i,:)'))', (b(i) - A(i,:) * d)])) >= -1e-3);
    end
  end
  A = [A; A_bounds];
  b = [b; b_bounds];

  if require_containment
    if all(A * start <= b) || iter == 1 || infeas_start
      results.p_history{iter} = struct('A', A, 'b', b);
    else
      hist = results.p_history{iter-1};
      A = hist.A;
      b = hist.b;
      disp('Breaking early because start point is no longer contained in polytope');
      break
    end
  else
    results.p_history{iter} = struct('A', A, 'b', b);
  end
  callback(A,b,C,d,obstacles);

  tic
  [C, d, cvx_optval] = maximize_ellipse_in_polyhedron(A,b,C,d);
  results.e_time = results.e_time + toc;
  results.e_history{iter+1} = struct('C', C, 'd', d);

  callback(A,b,C,d,obstacles);
  if abs(cvx_optval - best_vol)/best_vol < 2e-2
    break
  end
  best_vol = cvx_optval;
  iter = iter + 1;
end

results.iters = iter;
results.total_time = cputime() - t0;
