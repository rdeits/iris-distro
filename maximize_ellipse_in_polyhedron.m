function [C, d, volume] = maximize_ellipse_in_polyhedron(A,b,C,d)
import mosek_lownerjohn.lownerjohn_inner;

dim = size(A,2);


[C,d] = lownerjohn_inner(A,b);
  
%   cvx_begin sdp quiet
%     cvx_solver Mosek
%     variable C(dim,dim) semidefinite
%     variable d(dim)
%   %   maximize(log_det(C));
%     maximize(det_rootn(C))
%   %     maximize(trace(C))
%     subject to
%       for i = 1:length(b)
%         [(b(i) - A(i,:) * d) * eye(dim), C * (A(i,:)');
%          (C * (A(i,:)'))', (b(i) - A(i,:) * d)] >= 0;
%       end
%   cvx_end

volume = det(C);

