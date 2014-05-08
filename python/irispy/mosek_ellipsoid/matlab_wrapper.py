import sys

from scipy.io import loadmat, savemat
from irispy.mosek_ellipsoid.lownerjohn_ellipsoid import lownerjohn_inner

"""
MATLAB wrapper to the python lownerjohn_inner function (the MATLAB interface to Mosek Fusion fails after any call to 'clear java', so we can use this interface instead).

usage:
    python -m irispy.mosek.matlab_wrapper fname

where fname is a .mat file containing matrix A and vector b. Results will be stored in the same file.

Example usage from MATLAB:

    function [C, d] = py_lownerjohn_inner(A, b)
      fname = tempname();
      save(fname, 'A', 'b');
      system(['python -m irispy.mosek.matlab_wrapper ', fname]);
      load(fname, 'C', 'd');
      d = reshape(d, [], 1);
    end
"""

fname = sys.argv[1]

matvars = loadmat(fname, mat_dtype=True)
A = matvars['A']
b = matvars['b'].reshape((-1))
print 'A', A.dtype
print 'b', b.dtype

[C, d] = lownerjohn_inner(A, b);

savemat(fname, {'C': C, 'd': d})