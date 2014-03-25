function poly_segmentation_3d(record)
if nargin < 1
  record = false;
end
import iris.drawing.*;

lb = [0;0;0];
ub = [10;10;10];

n_obs = 20;
obstacles = {};
obs_offsets = 1*[0.5, 0.5, -0.5, -0.5, 0.5, 0.5, -0.5, -0.5;
                   -0.5, 0.5, 0.5, -0.5, -0.5, 0.5, 0.5, -0.5;
                   -0.5,-0.5,-0.5,-0.5, 0.5, 0.5, 0.5, 0.5];
for j = 1:n_obs
  center = random('uniform', 0, ub(1), 3, 1);
  obstacles{j} = bsxfun(@plus, center, obs_offsets);
end


A_bounds = [-1,0,0;
            0,-1,0;
            0,0,-1;
            1,0,0;
            0,1,0;
            0,0,1];
b_bounds = [-lb;ub];

start = 0.5 * (ub + lb);



[A,b,C,d,results] = iris.inflate_region(obstacles, A_bounds, b_bounds, start);
animate_results(results, record);

end
