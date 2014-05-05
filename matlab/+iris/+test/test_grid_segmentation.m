function test_grid_segmentation()
load('example_feas_map')
grid = Q(85:125,25:85);
% grid = Q;

clf;
imshow(grid);
hold on;

% profile on
obstacles = iris.terrain_grid.segment_grid(grid);
% profile viewer
for j = 1:length(obstacles)
  obs = obstacles{j};
  plot(obs(2,:), obs(1,:), 'r.-');
end

end

