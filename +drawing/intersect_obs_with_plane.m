function [ pts ] = intersect_obs_with_plane(obs, dim)
% Find the 2D or 3D intersection of the N-d convex body defined by 
% vertices obs with the x4 = x5 = .... = xN = 0 surface.

pts = [];
N = size(obs, 1);
for j = 1:size(obs, 2)
  for k = 1:size(obs, 2)
      if all(sign(obs(dim+1:end,j)) ~= sign(obs(dim+1:end,k)))
        d1 = abs(obs(:,j)' * [zeros(dim,1); ones(N - dim, 1)]);
        d2 = abs(obs(:,k)' * [zeros(dim,1); ones(N - dim, 1)]);
        intersect = (d2 * obs(:,j) + d1 * obs(:,k)) / (d1 + d2);
        pts(:,end+1) = intersect(1:dim);
      end
  end
end
try
  k = convhull(pts(1,:), pts(2,:), 'simplify', true);
catch
  k = 1:size(pts,2);
end
pts = pts(:,k);

end

