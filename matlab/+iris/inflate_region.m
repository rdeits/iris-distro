function [A, b, C, d, results] = inflate_region(obstacles, A_bounds, b_bounds, start, varargin)
import iris.*;

p = inputParser();
p.addOptional('require_containment', false, @isnumeric);
p.addOptional('error_on_infeasible_start', false, @isnumeric);
p.addOptional('termination_threshold', 2e-2, @(x) x > 0);
p.addOptional('iter_limit', 100, @isnumeric);
p.parse(varargin{:});
options = p.Results;

if exist('+iris/inflate_regionmex', 'file')
  disp('using c++ IRIS library')

  if ~iscell(obstacles)
    obstacle_cell = cell(1, size(obstacles, 3));
    for i = 1:size(obstacles, 3)
      obstacle_cell{i} = obstacles(:,:,i);
    end
    obstacles = obstacle_cell;
  end

  if nargout > 4
    [A, b, C, d, p_history, e_history] = inflate_regionmex(obstacles, A_bounds, b_bounds, start, options);
    results = inflation_results();
    results.start = start;
    results.obstacles = obstacles;
    results.n_obs = numel(obstacles);
    results.e_history = e_history;
    results.p_history = p_history;
  else
    [A, b, C, d] = inflate_regionmex(obstacles, A_bounds, b_bounds, start, options);
  end
else
  disp('falling back to Matlab-only library');
  [A, b, C, d, results] = inflate_region_fallback(obstacles, A_bounds, b_bounds, start, options);
end
