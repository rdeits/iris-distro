import numpy as np


def fromBounds(cls, lb, ub):
    """
    Return a new Polyhedron representing an n-dimensional box spanning
    from [lb] to [ub]
    """
    lb = np.asarray(lb, dtype=np.float64)
    ub = np.asarray(ub, dtype=np.float64)
    p = cls()
    p.setA(np.vstack((np.eye(lb.size), -np.eye(lb.size))))
    p.setB(np.hstack((ub, -lb)))
    return p

# For backward compatibility
from_bounds = fromBounds

def getDrawingVertices(self):
    return np.vstack(self.generatorPoints())