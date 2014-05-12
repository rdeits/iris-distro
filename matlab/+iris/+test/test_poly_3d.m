function results = poly_segmentation_3d(record)
if nargin < 1
  record = false;
end
import iris.drawing.*;

lb = [0;0;0];
ub = [10;10;10];
dim = 3;

n_obs = 20;
obs_offsets = 3*[0.5, 0.5, -0.5, -0.5, 0.5, 0.5, -0.5, -0.5;
                   -0.5, 0.5, 0.5, -0.5, -0.5, 0.5, 0.5, -0.5;
                   -0.5,-0.5,-0.5,-0.5, 0.5, 0.5, 0.5, 0.5];
obs_centers = rand(dim*n_obs, 1) .* (ub(1) - lb(1)) + lb(1);
obs_pts = bsxfun(@plus, obs_centers, repmat(obs_offsets ./ sqrt(n_obs), n_obs, 1));
obstacles = mat2cell(obs_pts, dim*ones(n_obs,1), size(obs_offsets,2))';



A_bounds = [-1,0,0;
            0,-1,0;
            0,0,-1;
            1,0,0;
            0,1,0;
            0,0,1];
b_bounds = [-lb;ub];

start = 0.5 * (ub + lb);


profile on
[A,b,C,d,results] = iris.inflate_region(obstacles, A_bounds, b_bounds, start);
profile viewer
animate_results(results, record);

end
