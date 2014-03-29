function [ results ] = test_poly_Nd(N, record)
% Demonstrate that we can apply the algorithm in arbitrary dimension

import iris.inflate_region;
import iris.drawing.*;

if nargin < 2
  record = false;
end

lb = -ones(N,1);
ub = ones(N,1);
dim = N;

obstacles = {};
n_obs = 50;
for j = 1:n_obs
  center = random('uniform', lb(1), ub(1), dim, 1);
  offsets = random('uniform', -0.3, 0.3, dim, 2^dim);
  obstacles{j} = bsxfun(@plus, center, offsets);
end

A_bounds = [];
for j = 1:dim
  row = zeros(1,dim);
  row(j) = -1;
  A_bounds(j,:) = row;
  b_bounds(j) = -lb(j);
end
for j = 1:dim
  row = zeros(1,dim);
  row(j) = 1;
  A_bounds(end+1,:) = row;
  b_bounds(end+1) = ub(j);
end
b_bounds = reshape(b_bounds,[],1);

start = 0.5 * (ub + lb);

profile on
[A,b,C,d,results] = inflate_region(obstacles, A_bounds, b_bounds, start, []);
profile viewer

animate_results(results, record);


end

