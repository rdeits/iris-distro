function results = test_c_space_3d(record)
import iris.cspace.cspace3;
import iris.inflate_region;
import iris.drawing.*;

if nargin < 1
  record = false;
end

dim = 3;
obstacles = {};
base_obstacles = {};
n_obs = 10;
obs_offsets = 1/n_obs^(1/3)*0.3*[0.5, 0.5, -0.5, -0.5;
                   -0.5, 0.5, 0.5, -0.5];
bot = [-0.005,-0.005,0.005,0.005;-0.3,0.3,0.3,-0.3];
for j = 1:n_obs
  center = random('uniform', 0, 4, 2, 1);
  base_obstacle = bsxfun(@plus, center, obs_offsets);
  base_obstacles{j} = base_obstacle;
  c_space_obs = cspace3(base_obstacle, bot, 10);
  obstacles = [obstacles, c_space_obs];
end
lb = [0;0;-pi];
ub = [4;4;pi];
A_bounds = [-1,0,0;
            0,-1,0;
            0,0,-1;
            1,0,0;
            0,1,0;
            0,0,1];
b_bounds = [-lb;ub];
start = 0.5 * (lb + ub);

% profile on
[A,b,C,d,results] = inflate_region(obstacles, A_bounds, b_bounds, start);
% profile viewer
% animate_results(results, record);
figure(4)
clf
hold on
for j = 1:length(base_obstacles)
  obs = base_obstacles{j};
  patch(obs(1,:), obs(2,:), 'k');
end
x = iris.sample_convex_polytope(A,b,50);
for k = 1:size(x,2)
  R = rotmat(x(3,k));
  bot_x = bsxfun(@plus, R * bot, x(1:2,k));
  patch(bot_x(1,:), bot_x(2,:), 'k');
end
axis equal
lb = lb - 0.3;
ub = ub + 0.3;
plot([lb(1),ub(1),ub(1),lb(1),lb(1)], [lb(2),lb(2),ub(2),ub(2),lb(2)], 'k--')
project_c_space_region(gcf, A, b);
axis off
end