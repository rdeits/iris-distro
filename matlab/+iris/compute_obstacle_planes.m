function [A, b, infeas_start] = compute_obstacle_planes(obstacles, obstacle_pts, C, d, obs_lcon)

  dim = size(C,1);
  infeas_start = false;
  Cinv = inv(C);
  pts_per_obs = size(obstacles{1},2);
  planes_to_use = false(length(obstacles),1);
  uncovered_obstacles = true(length(obstacles),1);
  image_pts = Cinv * bsxfun(@minus, obstacle_pts, d);
  image_dists = sum(image_pts.^2, 1);
  obs_image_dists = min(reshape(image_dists', pts_per_obs, []), [], 1);
  [~, obs_sort_idx] = sort(obs_image_dists);

  A = zeros(length(obstacles),dim);
  b = zeros(length(obstacles),1);

  clear prob;
  clear model params;
  [~, res] = mosekopt('symbcon echo(0)');

  for i = obs_sort_idx;
    if ~uncovered_obstacles(i)
      continue
    end

    obs = obstacles{i};
    % TODO: we've already computed all the ys above
    ys = Cinv*(bsxfun(@minus, obs, d));

    dists = sum(ys.^2);
    [~,idx] = min(dists);
    yi = ys(:,idx);
    xi = C*yi + d;
    nhat = 2 * Cinv * Cinv' * (xi - d);
    nhat = nhat / norm(nhat);
    b0 = nhat' * xi;
    if all(nhat' * obs - b0 >= 0)
      % nhat is feasible, so we can skip the optimization
      A(i,:) = nhat';
      b(i) = b0;
    else
       nw = size(ys,2);
%         [~, res] = mosekopt('symbcon echo(0)');
      nvar= 1 + dim+nw;
      prob.c   = [zeros(1, dim+nw) , 1];
      prob.a   = sparse([ [-eye(dim), ys, zeros(dim,1)];[ zeros(1,dim), ones(1,nw),0] ]);
      prob.blc = [zeros(dim,1);1];
      prob.buc = [zeros(dim,1);1];
      prob.blx = [-inf*ones(dim,1);zeros(nw+1,1)];
      prob.bux = inf*ones(nvar,1);

      % Specify the cones.
      prob.cones.type   = [res.symbcon.MSK_CT_QUAD];
      prob.cones.sub    = [nvar, 1:dim];
      prob.cones.subptr = [1];

      % Optimize the problem.
      [~,solution]=mosekopt('minimize echo(0)',prob);
      %toc
      ystar = solution.sol.itr.xx(1:dim);

%       if isempty(obs_lcon{i})
%         [G, h] = vert2lcon(obstacles{i}');
%         obs_lcon{i} = {G,h};
%       end
%       G = obs_lcon{i}{1};
%       h = obs_lcon{i}{2};
%       G2 = G * C;
%       h2 = h - G * d;
%       tic
%
%       % TODO: LDP approach seems to fail when the obstacle
%       % has no interior
%       ystar = ldp(-G2, -h2);

      if norm(ystar) < 1e-3
        % d is inside the obstacle. So we'll just reverse nhat to try to push the
        % ellipsoid out of the obstacle.
        disp('Warning: ellipse center is inside an obstacle.');
        infeas_start = true;
%         error('IRIS:InfeasibleStart', 'ellipse center is inside an obstacle');
        A(i,:) = -nhat';
        b(i) = -nhat' * xi;
      else
        xstar = C*ystar + d;
        nhat = 2 * Cinv * Cinv' * (xstar - d);
        nhat = nhat / norm(nhat);
%         valuecheck(nhat, transformed_normal(ystar, C), 1e-6);
%         nhat = transformed_normal(ystar, C);
        A(i,:) = nhat;
        b(i) = nhat' * xstar;
      end
    end

    check = bsxfun(@ge, A(i,:) * obstacle_pts, b(i));
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