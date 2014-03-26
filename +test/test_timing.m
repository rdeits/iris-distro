function [all_results] = test_timing(dim)

lb = zeros(dim,1);
ub = 10 * ones(dim,1);
n_samples = 6;
n_trials = 10;
ns_obs = logspace(1, 6, n_samples);
if dim == 2
  obs_offsets = [0.5, 0.5, -0.5, -0.5;
                       -0.5, 0.5, 0.5, -0.5];
  A_bounds = [-1,0;0,-1;1,0;0,1];
elseif dim == 3
  obs_offsets = [0.5, 0.5, -0.5, -0.5, 0.5, 0.5, -0.5, -0.5;
                   -0.5, 0.5, 0.5, -0.5, -0.5, 0.5, 0.5, -0.5;
                   -0.5,-0.5,-0.5,-0.5, 0.5, 0.5, 0.5, 0.5];
  A_bounds = [-1,0,0;
              0,-1,0;
              0,0,-1;
              1,0,0;
              0,1,0;
              0,0,1];
end

b_bounds = [-lb; ub];
all_results = iris.inflation_results.empty();

start = 0.5 * (ub + lb);
for j = 1:n_samples
  for k = 1:n_trials
    n_obs = round(ns_obs(j))
    obs_centers = random('uniform', lb(1), ub(1), dim*n_obs, 1);
    obs_pts = bsxfun(@plus, obs_centers, repmat(obs_offsets ./ sqrt(n_obs), n_obs, 1));
    obstacles = mat2cell(obs_pts, dim*ones(n_obs,1), size(obs_offsets,2))';
    [A,b,C,d,results] = iris.inflate_region(obstacles, A_bounds, b_bounds, start, []);
    results.obstacles = [];
    all_results(k,j) = results;
  end
end

