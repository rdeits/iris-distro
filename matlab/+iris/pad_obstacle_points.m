function padded_obstacles = pad_obstacle_points(obstacles)

padded_obstacles = obstacles;
max_len = 0;
for j = 1:length(obstacles)
  l = size(obstacles{j},2);
  if l > max_len
    max_len = l;
  end
end

for j = 1:length(obstacles)
  if size(obstacles{j}, 2) < max_len
    obs = obstacles{j};
    padded_obstacles{j} = [obs, repmat(obs(:,end), 1, max_len - size(obs,2))];
  end
end
