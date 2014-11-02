function results = test_thin_ellipsoid(record)
if nargin < 1
  record = false;
end
import iris.drawing.*;

lb = [0;0;0];
ub = [10;10;10];
dim = 3;

obstacles = create_map_3d(lb, ub)
n_obs = size(obstacles,3);

A_bounds = [-1,0,0;
            0,-1,0;
            0,0,-1;
            1,0,0;
            0,1,0;
            0,0,1];
b_bounds = [-lb;ub];

% start = 0.25 * (ub + lb);
start = [1.1;1;0.5];

% profile on
options = struct();
options.require_containment = true;
[A,b,C,d,results] = iris.inflate_region(obstacles, A_bounds, b_bounds, start, options);

if det(results.e_history{2}.C) <= 1
  error('IRIS:ThinEllipsoidIssue', 'There is a known issue which causes very thin ellipsoid for this particular environment. See https://github.com/rdeits/iris-distro/issues/2');
end

end

function obstacle_pts = create_map_3d(lb, ub, scale)
% Generate a randomly distributed field of cubic obstacles
if nargin < 5
  scale = 3;
end
dim = 3;
offsets = scale * [1, 1, -1, -1, 1, 1, -1, -1;
                   -1, 1, 1, -1, -1, 1, 1, -1;
                   -1,-1,-1,-1, 1, 1, 1, 1];
               
centers_unit = [0.5;
                0.5;
                0.5];
n_obs = size(centers_unit, 2);
            
centers = bsxfun(@plus, bsxfun(@times, centers_unit, ub - lb), lb);
centers = reshape(centers, dim, 1, []);
obstacle_pts = bsxfun(@plus, centers, repmat(offsets ./ (n_obs^(1/dim)), [1,1, n_obs]));

end
