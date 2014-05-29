function test_ellipsoid()
% Benchmark inscribed ellipsoid algorithms and make sure they agree

inputs = {};
n = 20;
for j = 1:n
  dim = randi([2,5],1);
  lb = rand(dim,1) * 2 - 1;
  ub = lb + rand(1) + 1;
  inputs{end+1} = struct('A', [-diag(ones(dim,1)); diag(ones(dim,1))],...
                         'b', [-lb; ub]);
end


for j = 1:n
  A = inputs{j}.A;
  b = inputs{j}.b;
  [C, d] = iris.inner_ellipsoid.mosek_ellipsoid(A, b);
  
  [C_cvx, d_cvx] = iris.inner_ellipsoid.cvx_ellipsoid(A, b);
  valuecheck(C_cvx, C, 1e-3);
  valuecheck(d_cvx, d, 1e-3);
  
  [C_pym, d_pym] = iris.inner_ellipsoid.py_mosek_ellipsoid(A, b);
  valuecheck(C_pym, C, 1e-3);
  valuecheck(d_pym, d, 1e-3);
  
  [C_sp, d_sp] = iris.inner_ellipsoid.spot_ellipsoid(A, b);
  valuecheck(C_sp, C, 1e-3);
  valuecheck(d_sp, d, 1e-3);
  
end

tic
for j = 1:n
  [C, d] = iris.inner_ellipsoid.mosek_ellipsoid(A,b);
end
fprintf('mosek: %f s\n', toc/n);

tic
for j = 1:n
  [C, d] = iris.inner_ellipsoid.cvx_ellipsoid(A,b);
end
fprintf('cvx: %f s\n', toc/n);

tic
for j = 1:n
  [C, d] = iris.inner_ellipsoid.py_mosek_ellipsoid(A,b);
end
fprintf('py mosek: %f s\n', toc/n);

tic
for j = 1:n
  [C, d] = iris.inner_ellipsoid.spot_ellipsoid(A,b);
end
fprintf('spot: %f s\n', toc/n);