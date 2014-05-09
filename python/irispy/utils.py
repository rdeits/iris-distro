import cdd
import numpy as np

class InfeasiblePolytopeError(Exception):
    pass

def lcon_to_vert(A, b):
    # print "A", repr(A)
    # print "b", repr(b)
    rows0 = np.hstack((b.reshape((-1,1)), -A))
    # pycddlib seems to occasionally crash for certain polytopes. Reducing the precision of A and b fixes this for some reason.
    rows = np.array(rows0, dtype=np.float16)
    mat = cdd.Matrix(rows)
    mat.rep_type = cdd.RepType.INEQUALITY
    poly = cdd.Polyhedron(mat)
    ext = poly.get_generators()
    if len(ext) == 0:
        raise(InfeasiblePolytopeError("Ax <= b is infeasible; no vertices can be found"))
    return np.hstack((np.reshape(row[1:], (-1,1)) for row in ext))