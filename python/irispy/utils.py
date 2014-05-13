import polyhedron._cdd
from polyhedron import Hrep

class InfeasiblePolytopeError(Exception):
    pass

def lcon_to_vert(A, b):
    try:
        return Hrep(A, b).generators.T
    except polyhedron._cdd.error:
        return None
