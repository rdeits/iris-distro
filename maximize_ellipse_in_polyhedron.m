function [C, d, volume] = maximize_ellipse_in_polyhedron(A,b,C,d)
import mosek_lownerjohn.lownerjohn_inner;

dim = size(A,2);


try
  [C,d] = lownerjohn_inner(A,b);
catch exception
  disp(getReport(exception));
  fprintf(1, 'Warning: Mosek Fusion call failed. Falling back to CVX');
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

volume = det(C);

