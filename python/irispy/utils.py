from polyhedron import Hrep

class InfeasiblePolytopeError(Exception):
    pass

def lcon_to_vert(A, b):
    return Hrep(A, b).generators.T
