function [C, d] = mosek_nofusion(A, b)
% 
% A = [-diag(ones(3,1)); diag(ones(3,1))];
% b = [0;0;0;1;1;1];

[m, n] = size(A);
l = ceil(log2(n));

num.t = 1;
num.d = n;
num.s = 2^l - 1;
num.sprime = num.s;
num.z = 2^l;
num.f = m * n;
num.g = m;

nvar = 0;
for v = {'t', 'd', 's', 'sprime', 'z', 'f', 'g'}
  var = v{1};
  ndx.(var) = nvar + (1:num.(var));
  nvar = nvar + num.(var);
end
ndx.f = reshape(ndx.f, m, n);

ncon = n * m + m + n + n + (2^l - n) + 1 + (n * (n-1) / 2) + (2^l - 1);

clear prob
% [r, res] = mosekopt('symbcon');
MSK_CT_RQUAD = 1;
MSK_CT_QUAD = 0;

prob.c = zeros(nvar, 1);

% maximize t
prob.c(ndx.t) = 1;

% Y \in S^{2n}_+
prob.bardim = 2*n;

prob.a = zeros(ncon, nvar);
prob.blc = -inf(ncon,1);
prob.buc = inf(ncon,1);

prob.bara.subi = [];
prob.bara.subj = [];
prob.bara.subk = [];
prob.bara.subl = [];
prob.bara.val = [];

prob.cones.type = [];
prob.cones.sub = [];
prob.cones.subptr = [];

con_ndx = 1;
for i = 1:m
  % a_i^T C = [f_{i,1}, f_{i,2}, ..., f_{i,n}]
  for j = 1:n
    % (a_i^T C)_j = f_{i,j}
    prob.bara.subi = [prob.bara.subi, repmat(con_ndx, 1, n)];
    prob.bara.subj = [prob.bara.subj, ones(1, n)];
    
    % Do some silliness because Mosek will fail if we try to specify
    % elements of Abar above the diagonal. 
    subk = repmat(j, 1, n);
    subl = 1:n;
    swap_mask = subk < subl;
    swap = subk(swap_mask);
    subk(swap_mask) = subl(swap_mask);
    subl(swap_mask) = swap;
    
    prob.bara.subk = [prob.bara.subk, subk];
    prob.bara.subl = [prob.bara.subl, subl];
    prob.bara.val = [prob.bara.val, A(i,:)];
    prob.a(con_ndx, ndx.f(i,j)) = -1;
    prob.blc(con_ndx) = 0;
    prob.buc(con_ndx) = 0;
    con_ndx = con_ndx + 1;
  end
  prob.a(con_ndx, ndx.d) = A(i,:);
  prob.a(con_ndx, ndx.g(i)) = 1;
  prob.blc(con_ndx) = b(i);
  prob.buc(con_ndx) = b(i);
  con_ndx = con_ndx + 1;
end

% for j = 1:n
%   % Xbar_{n+j,j} == z_j
%   prob.bara.subi = [prob.bara.subi, con_ndx];
%   prob.bara.subj = [prob.bara.subj, 1];
%   prob.bara.subk = [prob.bara.subk, n+j];
%   prob.bara.subl = [prob.bara.subl, j];
%   prob.bara.val = [prob.bara.val, 1];
%   prob.a(con_ndx, ndx.z(j)) = -1;
%   prob.blc(con_ndx) = 0;
%   prob.buc(con_ndx) = 0;
%   con_ndx = con_ndx + 1;
% end

for j = 1:n
  % Xbar_{n+j,n+j} == z_j
  prob.bara.subi = [prob.bara.subi, con_ndx];
  prob.bara.subj = [prob.bara.subj, 1];
  prob.bara.subk = [prob.bara.subk, n+j];
  prob.bara.subl = [prob.bara.subl, j];
  prob.bara.val = [prob.bara.val, 1];
  prob.a(con_ndx, ndx.z(j)) = -1;
  prob.blc(con_ndx) = 0;
  prob.buc(con_ndx) = 0;
  con_ndx = con_ndx + 1;
end

for j = 1:n
  % Xbar_{n+j,n+j} == z_j
  prob.bara.subi = [prob.bara.subi, con_ndx];
  prob.bara.subj = [prob.bara.subj, 1];
  prob.bara.subk = [prob.bara.subk, n+j];
  prob.bara.subl = [prob.bara.subl, n+j];
  prob.bara.val = [prob.bara.val, 1];
  prob.a(con_ndx, ndx.z(j)) = -1;
  prob.blc(con_ndx) = 0;
  prob.buc(con_ndx) = 0;
  con_ndx = con_ndx + 1;
end

for j = n+1:2^l
  % z_j == t for j > n
  prob.a(con_ndx, ndx.z(j)) = 1;
  prob.a(con_ndx, ndx.t) = -1;
  prob.blc(con_ndx) = 0;
  prob.buc(con_ndx) = 0;
  con_ndx = con_ndx + 1;
end

% Off-diagonal elements of Y22 are 0
for k = n+1:(2*n-1)
  for j = k+1:2*n
    prob.bara.subi = [prob.bara.subi, con_ndx];
    prob.bara.subj = [prob.bara.subj, 1];
    prob.bara.subk = [prob.bara.subk, j];
    prob.bara.subl = [prob.bara.subl, k];
    prob.bara.val = [prob.bara.val, 1];
    prob.blc(con_ndx) = 0;
    prob.buc(con_ndx) = 0;
    con_ndx = con_ndx + 1;
  end
end

% 2^(l/2)t == s_{2l - 1}
prob.a(con_ndx, ndx.t) = 2^(l/2);
prob.a(con_ndx, ndx.s(end)) = -1;
prob.blc(con_ndx) = 0;
prob.buc(con_ndx) = 0;
con_ndx = con_ndx + 1;


% s_j == sprime_j
for j = 1:(2^l - 1)
  prob.a(con_ndx, ndx.s(j)) = 1;
  prob.a(con_ndx, ndx.sprime(j)) = -1;
  prob.blc(con_ndx) = 0;
  prob.buc(con_ndx) = 0;
  con_ndx = con_ndx + 1;
end

assert(con_ndx == ncon + 1);

cone_ptr = 1;
lhs = [ndx.z, ndx.sprime];
lhs_ptr = 1;
for j = 1:(2^l - 1)
  prob.cones.type = [prob.cones.type, MSK_CT_RQUAD];
  prob.cones.sub = [prob.cones.sub, lhs(lhs_ptr:lhs_ptr+1), ndx.s(j)];
  prob.cones.subptr = [prob.cones.subptr, cone_ptr];
  lhs_ptr = lhs_ptr + 2;
  cone_ptr = cone_ptr + 3;
end

% prob.cones.type = [prob.cones.type, res.symbcon.MSK_CT_RQUAD];
% prob.cones.sub = [prob.cones.sub, ndx.z(1), ndx.z(2), ndx.s(1)];
% prob.cones.subptr = [prob.cones.subptr, cone_ptr];
% cone_ptr = cone_ptr + 3;

for i = 1:m
  prob.cones.type = [prob.cones.type, MSK_CT_QUAD];
  prob.cones.sub = [prob.cones.sub, ndx.g(i), ndx.f(i,:)];
  prob.cones.subptr = [prob.cones.subptr, cone_ptr];
  cone_ptr = cone_ptr + n + 1;
end

prob.a = sparse(prob.a);
[r, res] = mosekopt('maximize echo(0)', prob);

Y = zeros(2*n, 2*n);
flat_ndx = 1;
for k = 1:2*n
  for j = k:2*n
    Y(j,k) = res.sol.itr.barx(flat_ndx);
    flat_ndx = flat_ndx + 1;
  end
end
Y = Y + tril(Y,-1)';
Y;
C = Y(1:n, 1:n);
d = res.sol.itr.xx(ndx.d);
f = res.sol.itr.xx(ndx.f);
g = res.sol.itr.xx(ndx.g);
z = res.sol.itr.xx(ndx.z);
t = res.sol.itr.xx(ndx.t);
s = res.sol.itr.xx(ndx.s);
sprime = res.sol.itr.xx(ndx.sprime);

for j = 1:2^l
  if j <= n
    assert(abs(z(j) - Y(n+j,n+j)) < 1e-4);
  else
    assert(abs(z(j) - t) < 1e-4);
  end
end

for i = 1:m
  assert(all(abs(A(i,:) * C - f(i,:)) < 1e-4));
  assert(all(abs(b(i) - A(i,:) * d - g(i)) < 1e-4));
end
% assert(all(all((abs(diag(diag(Y(n+1:2*n,1:n))) - Y(n+1:2*n,n+1:2*n)) < 1e-4))));

assert(abs(2^(l/2) * t - s(end)) < 1e-4);

Y22 = Y(n+1:2*n, n+1:2*n);
assert(all(all(abs(Y22 - diag(diag(Y22))) < 1e-4)));

assert(all(abs(s - sprime) < 1e-4));
% assert(abs(t - (det(C) ^ (1/n))) < 1e-4);