import sys

from scipy.io import loadmat, savemat
from irispy.mosek.lownerjohn_ellipsoid import lownerjohn_inner

fname = sys.argv[1]

matvars = loadmat(fname, mat_dtype=True)
A = matvars['A']
b = matvars['b'].reshape((-1))
print 'A', A.dtype
print 'b', b.dtype

[C, d] = lownerjohn_inner(A, b);

savemat(fname, {'C': C, 'd': d})