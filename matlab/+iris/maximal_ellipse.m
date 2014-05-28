function [C, d, volume] = maximal_ellipse(A,b)

try
  [C,d] = iris.inner_ellipsoid.mosek_ellipsoid(A,b);
catch exception
  disp(exception.message);
  disp('Warning: Mosek Fusion call failed. Falling back to python interface');
  try
    [C, d] = iris.inner_ellipsoid.py_mosek_ellipsoid(A, b);
  catch exception
    disp(exception.message);
    disp('Warning: Mosek python call *also* failed. Trying one last time with CVX');
    [C, d] = iris.inner_ellipsoid.cvx_ellipsoid(A, b);
  end
end

volume = det(C);

