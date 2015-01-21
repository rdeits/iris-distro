function ystar = mosek_ldp(ys)
% Use Mosek to find the closest point in the convex hull of the ys to the
% origin.

DEBUG = false;

if DEBUG
  [~, res] = mosekopt('symbcon echo(0)');
  conetype= res.symbcon.MSK_CT_QUAD;
else
  % Mosek's docs tell us to use `[~, res] = mosekopt('symbcon echo(0)')` to look up the correct enum value for a quad cone type, but doing so takes longer than solving the actual problem, so we'll just hard-code it. We're fun like that. 
  conetype = 1;
end

dim = size(ys, 1);

nw = size(ys,2);
nvar= 1 + dim+nw;
prob.c   = [zeros(1, dim+nw) , 1];
prob.a   = sparse([ [-eye(dim), ys, zeros(dim,1)];[ zeros(1,dim), ones(1,nw),0] ]);
prob.blc = [zeros(dim,1);1];
prob.buc = [zeros(dim,1);1];
prob.blx = [-inf*ones(dim,1);zeros(nw+1,1)];
prob.bux = inf*ones(nvar,1);

% Specify the cones.
prob.cones.type   = conetype;
prob.cones.sub    = [nvar, 1:dim];
prob.cones.subptr = 1;

% Optimize the problem.
[~,solution]=mosekopt('minimize echo(0)',prob);
%toc
ystar = solution.sol.itr.xx(1:dim);

end

