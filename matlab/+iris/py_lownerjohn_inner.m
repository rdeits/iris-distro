function [C, d] = py_lownerjohn_inner(A, b)

fname = tempname();
save(fname, 'A', 'b');
system(['python -m irispy.mosek_ellipsoid.matlab_wrapper ', fname]);
load(fname, 'C', 'd');
d = reshape(d, [], 1);

end