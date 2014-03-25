function poly_segmentation_2d(record)
import iris.inflate_region;
import iris.drawing.*;

if nargin < 1
  record = false;
end

lb = [0;0];
ub = [10;10];

n_obs = 1000;
obstacles = cell(1,n_obs);
obs_offsets = 0.2*[0.5, 0.5, -0.5, -0.5;
                     -0.5, 0.5, 0.5, -0.5];
for j = 1:n_obs
  center = random('uniform', 0, ub(1), 2, 1);
  obstacles{j} = bsxfun(@plus, center, obs_offsets);
end
% load('bad_obstacles.mat', 'obstacles');

A_bounds = [-1,0;0,-1;1,0;0,1];
b_bounds = [-lb; ub];

start = 0.5 * (ub + lb);

% profile on
[A,b,C,d,results] = inflate_region(obstacles, A_bounds, b_bounds, start, []);
% profile viewer
animate_results(results, record);

end
