function [C, d] = py_mosek_ellipsoid(A, b)

fname = tempname();
save(fname, 'A', 'b');
system(['python -m irispy.mosek_ellipsoid.matlab_wrapper ', fname]);
load(fname, 'C', 'd');
d = reshape(d, [], 1);

end
