import numpy as np
import irispy

def lcon_to_vert(A, b):
    poly = irispy.Polyhedron(A.shape[1])
    poly.setA(A)
    poly.setB(b)
    V = np.vstack(poly.generatorPoints()).T

def sample_convex_polytope(A, b, nsamples):
    poly = irispy.Polyhedron(A.shape[1])
    poly.setA(A)
    poly.setB(b)
    generators = np.vstack(poly.generatorPoints())
    lb = np.min(generators, axis=0)
    ub = np.max(generators, axis=0)

    n = 0
    samples = np.zeros((len(lb), nsamples))
    while n < nsamples:
        z = np.random.uniform(lb, ub)
        if np.all(poly.A.dot(z) <= poly.b):
            samples[:,n] = z
            n += 1
    return samples