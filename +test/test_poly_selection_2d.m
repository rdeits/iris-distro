import iris.terrain_grid.*;
import iris.inflate_region;
import iris.thirdParty.polytopes.*;

load('example_feas_map.mat');
grid = Q(85:125,25:85);
[all_squares(1,:), all_squares(2,:)] = ind2sub(size(grid), 1:length(reshape(grid,[],1)));

while true
  figure(2)
  subplot(211)
  imshow(grid, 'InitialMagnification', 'fit')
  [c,r] = ginput(1);
  c = round(c);
  r = round(r);
  clear white_squares black_squares black_edges
  [white_squares(1,:), white_squares(2,:)] = ind2sub(size(grid), find(grid));
  [black_squares(1,:), black_squares(2,:)] = ind2sub(size(grid), find(~grid));
  black_edges = [];
  [black_edges(1,:), black_edges(2,:)] = ind2sub(size(grid), find(component_boundary(grid, [r;c])));

  obstacles = mat2cell(black_edges, 2, ones(1,size(black_edges,2)));

  lb = [0;0];
  ub = [size(grid,1); size(grid,2)];
  A_bounds = [-1,0;0,-1;1,0;0,1];
  b_bounds = [-lb; ub];

  [A,b,C,d] = inflate_region(obstacles, A_bounds, b_bounds, [r;c]);

  figure(2)
  subplot(212)
  cla
  hold on
  for j = 1:length(obstacles)
    patch(obstacles{j}(1,:), obstacles{j}(2,:), 'k');
  end
  V = lcon2vert(A, b);
  k = convhull(V(:,1), V(:,2));
  plot(V(k,1), V(k,2), 'ro-');
  th = linspace(0,2*pi,100);
  y = [cos(th);sin(th)];
  x = bsxfun(@plus, C*y, d);
  plot(x(1,:), x(2,:), 'b-');
  xlim([lb(1),ub(1)])
  ylim([lb(1),ub(2)])
  grid(all(bsxfun(@le, A * all_squares, b), 1)) = 0;
end