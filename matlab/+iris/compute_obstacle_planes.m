function [A, b, infeas_start] = compute_obstacle_planes(obstacle_pts, C, d)

  dim = size(C,1);
  infeas_start = false;
  n_obs = size(obstacle_pts, 3);
  pts_per_obs = size(obstacle_pts, 2);
  Cinv = inv(C);
  Cinv2 = (Cinv * Cinv');
  if n_obs == 0
    A = zeros(0, dim);
    b = zeros(0, 1);
    infeas_start = false;
    return;
  end

  uncovered_obstacles = true(n_obs,1);
  planes_to_use = false(n_obs, 1);

  % image_pts = reshape(Cinv * bsxfun(@minus, reshape(obstacle_pts, dim, []), d), size(obstacle_pts));
  % image_dists = sum(image_pts.^2, 1);
  % obs_image_dists = min(reshape(image_dists', pts_per_obs, []), [], 1);
  % [~, obs_sort_idx] = sort(obs_image_dists);

  image_pts = reshape(Cinv * bsxfun(@minus, reshape(obstacle_pts, dim, []), d), size(obstacle_pts));
  image_dists = reshape(sum(image_pts.^2, 1), size(obstacle_pts, 2), size(obstacle_pts, 3));
  obs_image_dists = min(image_dists, [], 1);
  [~, obs_sort_idx] = sort(obs_image_dists);


  A = zeros(n_obs,dim);
  b = zeros(n_obs,1);

  [~, res] = mosekopt('symbcon echo(0)');

  for i = obs_sort_idx;
    if ~uncovered_obstacles(i)
      continue
    end

    obs = obstacle_pts(:,:,i);
    ys = image_pts(:,:,i);
    dists = image_dists(:,i);
    [~,idx] = min(dists);
    xi = obs(:,idx);
    nhat = 2 * Cinv2 * (xi - d);
    nhat = nhat / norm(nhat);
    b0 = nhat' * xi;
    if all(nhat' * obs - b0 >= 0)
      % nhat is feasible, so we can skip the optimization
      A(i,:) = nhat';
      b(i) = b0;
    else
      if all(size(ys) <= [3, 8])
        ystar = iris.cvxgen_ldp(ys);
      else
        ystar = iris.mosek_ldp(ys, res);
      end

      if norm(ystar) < 1e-3
        % d is inside the obstacle. So we'll just reverse nhat to try to push the
        % ellipsoid out of the obstacle.
        disp('Warning: ellipse center is inside an obstacle.');
        infeas_start = true;
        A(i,:) = -nhat';
        b(i) = -nhat' * xi;
      else
        xstar = C*ystar + d;
        nhat = 2 * Cinv2 * (xstar - d);
        nhat = nhat / norm(nhat);
        A(i,:) = nhat;
        b(i) = nhat' * xstar;
      end
    end

    check = bsxfun(@ge, A(i,:) * reshape(obstacle_pts, dim, []), b(i));
    check = reshape(check', pts_per_obs, []);
    excluded = all(check, 1);
    uncovered_obstacles(excluded) = false;

    planes_to_use(i) = true;
    uncovered_obstacles(i) = false;

    if ~any(uncovered_obstacles)
      break
    end

  end
  A = A(planes_to_use,:);
  b = b(planes_to_use);
end