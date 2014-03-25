function [A, b, C, d, results] = inflate_region(obstacles, A_bounds, b_bounds, start, callback)
import iris.*;

results = inflation_results();
results.start = start;
results.obstacles = obstacles;

tic
obs_lcon = cell(length(obstacles),1);
% for j = 1:length(obstacles)
%   [G, h] = vert2lcon(obstacles{j}');
%   obs_lcon{j} = {G, h};
% end
obstacles = pad_obstacle_points(obstacles);
obstacle_pts = cell2mat(obstacles);

if nargin < 5 || isempty(callback)
  callback = @callback_silent;
end

dim = size(A_bounds, 2);
d = start;
C = 0.01 * eye(dim);
best_vol = -inf;
volumes = [];
iter = 1;
ip_result = [];
results.e_history{1} = struct('C', C, 'd', d);

while true
  tic
  [A, b, obs_lcon] = compute_obstacle_planes(obstacles, obstacle_pts, C, d, obs_lcon);
  results.p_time = results.p_time + toc;
  if iter > 1
    for i = 1:length(b)
      assert(min(eig([(b(i) - A(i,:) * d) * eye(dim), C * (A(i,:)');
         (C * (A(i,:)'))', (b(i) - A(i,:) * d)])) >= -1e-3);
    end
  end
  A = [A; A_bounds];
  b = [b; b_bounds];
  results.p_history{iter} = struct('A', A, 'b', b);
  callback(A,b,C,d,obstacles);
  
  tic
  [C, d, cvx_optval] = maximize_ellipse_in_polyhedron(A,b,C,d);
  results.e_time = results.e_time + toc;
  results.e_history{iter+1} = struct('C', C, 'd', d);
  
  volumes(end+1) = cvx_optval;
  iter = iter + 1
  callback(A,b,C,d,obstacles);
  if abs(cvx_optval - best_vol)/best_vol < 2e-2
    break
  end
  best_vol = cvx_optval;
end

results.total_time = toc;
