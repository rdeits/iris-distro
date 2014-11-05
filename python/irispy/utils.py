import polyhedron._cdd
import numpy as np
from polyhedron import Hrep

class InfeasiblePolytopeError(Exception):
    pass

def lcon_to_vert(A, b):
    try:
        return Hrep(A, b).generators.T
    except polyhedron._cdd.error:
        return None


def sample_convex_polytope(A, b, nsamples):
    poly = Hrep(A, b);
    lb = np.min(poly.generators, axis=0)
    ub = np.max(poly.generators, axis=0)

    n = 0
    samples = np.zeros((len(lb), nsamples))
    while n < nsamples:
        z = np.random.uniform(lb, ub)
        if np.all(poly.A.dot(z) <= poly.b):
            samples[:,n] = z
            n += 1
    return samples