[~, res] = mosekopt('symbcon echo(0)');

ys = rand(2, 6);
n = 100;
tic
for j = 1:n
  iris.mosek_ldp(ys, res);
end
fprintf(1, 'mosek: %f\n', toc / n);

tic 
for j = 1:n
  iris.cvxgen_ldp(ys);
end
fprintf(1, 'cvxgen: %f\n', toc / n);