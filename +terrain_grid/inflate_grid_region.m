function mask = inflate_grid_region(~, seed_grid)
grid = logical(seed_grid);
[all_squares(1,:), all_squares(2,:)] = ind2sub(size(grid), 1:length(reshape(grid,[],1)));

dists = obs_dist(seed_grid);
[~, i0] = max(reshape(dists, [], 1));
[r, c] = ind2sub(size(grid), i0);
x0 = [r; c];

[white_squares(1,:), white_squares(2,:)] = ind2sub(size(grid), find(grid));
[black_squares(1,:), black_squares(2,:)] = ind2sub(size(grid), find(~grid));
black_edges = [];
[black_edges(1,:), black_edges(2,:)] = ind2sub(size(grid), find(component_boundary(grid, [r;c])));

obstacles = {};
obs_offsets = [0.5, 0.5, -0.5, -0.5;
                   -0.5, 0.5, 0.5, -0.5];
for j = 1:size(black_edges,2)
  center = black_edges(:,j);
  obstacles{j} = bsxfun(@plus, center, obs_offsets);
end

% obstacles = mat2cell(black_edges, 2, ones(1,size(black_edges,2)));

lb = [0;0];
ub = [size(grid,1); size(grid,2)];
A_bounds = [-1,0;0,-1;1,0;0,1];
b_bounds = [-lb; ub];

[A,b,C,d] = inflate_region(obstacles, A_bounds, b_bounds, x0);

% figure(2)
% cla
% hold on
% for j = 1:length(obstacles)
%   patch(obstacles{j}(1,:), obstacles{j}(2,:), 'k');
% end
% V = lcon2vert(A, b);
% k = convhull(V(:,1), V(:,2));
% plot(V(k,1), V(k,2), 'ro-');
% th = linspace(0,2*pi,100);
% y = [cos(th);sin(th)];
% x = bsxfun(@plus, C*y, d);
% plot(x(1,:), x(2,:), 'b-');
% xlim([lb(1),ub(1)])
% ylim([lb(1),ub(2)])

for i = 1:size(A,2)
  n = norm(A(i,:));
  A(i,:) = A(i,:) / n;
  b(i) = b(i) / n;
end
mask = zeros(size(grid));
mask(all(bsxfun(@minus, A * all_squares, b) < 0.5, 1)) = 1;
mask(~grid) = 0;
