from __future__ import division

import numpy as np
import os

MAX_SIZE = (3,8)

_cvxgen_lib = np.ctypeslib.load_library('cvxgen_ldp.so', os.path.dirname(os.path.realpath(__file__)))

array_1d_double = np.ctypeslib.ndpointer(dtype=np.double, ndim=1, flags='CONTIGUOUS')

_cvxgen_lib.cvxgen_ldp.argtypes = [np.ctypeslib.ndpointer(dtype=np.double, ndim=1,
                                                          flags='CONTIGUOUS',
                                                          shape=(24,)),
                                   np.ctypeslib.ndpointer(dtype=np.double, ndim=1,
                                                          flags='CONTIGUOUS',
                                                          shape=(3,))]
_cvxgen_lib.cvxgen_ldp.restype = None

def ldp(Y):
    """
    Run the specialized custom C solver generated by CVXGEN on the least-distance-programming QP. This solver only works for Y of size [3 x 8], so we pad smaller matrices as needed.
    """
    dim = Y.shape[0]
    if dim < 3:
        Y = np.pad(Y, ((0, 3 - Y.shape[0]), (0,0)), mode='constant', constant_values=0)
    if Y.shape[1] < 8:
        Y = np.pad(Y, ((0,0), (0, 8 - Y.shape[1])), mode='edge')
    v = np.empty(3)
    _cvxgen_lib.cvxgen_ldp(Y.flatten(order='F'),v)
    return v[:dim]

