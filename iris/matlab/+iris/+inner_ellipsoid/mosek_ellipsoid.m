function [C, d] = mosek_ellipsoid(A, b)
import iris.thirdParty.mosek_lownerjohn.lownerjohn_ellipsoid;
[C,d] = lownerjohn_ellipsoid.lownerjohn_inner(A,b);
end
