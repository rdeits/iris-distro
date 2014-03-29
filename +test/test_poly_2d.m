function results = test_poly_2d(record)
import iris.inflate_region;
import iris.drawing.*;

if nargin < 1
  record = false;
end

lb = [0;0];
ub = [10;10];
dim = 2;

n_obs = 1000;
obs_offsets = 2*[0.5, 0.5, -0.5, -0.5;
                     -0.5, 0.5, 0.5, -0.5];
obs_centers = random('uniform', lb(1), ub(1), dim*n_obs, 1);
obs_pts = bsxfun(@plus, obs_centers, repmat(obs_offsets ./ sqrt(n_obs), n_obs, 1));
obstacles = mat2cell(obs_pts, dim*ones(n_obs,1), size(obs_offsets,2))';
% load('bad_obstacles.mat', 'obstacles');

A_bounds = [-1,0;0,-1;1,0;0,1];
b_bounds = [-lb; ub];

start = 0.5 * (ub + lb);

profile on
[A,b,C,d,results] = inflate_region(obstacles, A_bounds, b_bounds, start, []);
profile viewer
animate_results(results, record);

end
