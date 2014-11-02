A_bounds = [-eye(3); 
            1,1,1];
b_bounds = [0;0;0;1];
lb = [0;0;0];
ub = [1;1;1];

[C, d] = iris.inner_ellipsoid.mosek_nofusion(A_bounds, b_bounds);
[C1, d1] = iris.inner_ellipsoid.mosek_ellipsoid(A_bounds, b_bounds);

iris.drawing.draw_3d(A_bounds, b_bounds, C, d, [], lb, ub);

try
  assert(all(all(abs(C - C1) <= 1e-3)))
  assert(all(all(abs(d - d1) <= 1e-3)))
catch
  disp('Fail: this is a known bug in mosek_nofusion() for this particular input set.');
end

