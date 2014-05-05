function [C, d, volume] = maximize_ellipse_in_polyhedron(A,b,C,d)
import iris.thirdParty.mosek_lownerjohn.lownerjohn_ellipsoid;

dim = size(A,2);

try
  [C,d] = lownerjohn_ellipsoid.lownerjohn_inner(A,b);
catch exception
  disp(exception.message);
  disp('Warning: Mosek Fusion call failed. Falling back to python interface');
  try
    [C, d] = iris.py_lownerjohn_inner(A, b);
  catch exception
    disp(exception.message);
    disp('Warning: Mosek python call *also* failed. Trying one last time with CVX');
    cvx_begin sdp quiet
      cvx_solver Mosek
      variable C(dim,dim) semidefinite
      variable d(dim)
      maximize(det_rootn(C))
      subject to
        for i = 1:length(b)
          [(b(i) - A(i,:) * d) * eye(dim), C * (A(i,:)');
           (C * (A(i,:)'))', (b(i) - A(i,:) * d)] >= 0;
        end
    cvx_end
  end
end

volume = det(C);

