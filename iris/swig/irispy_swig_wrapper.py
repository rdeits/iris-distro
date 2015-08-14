import irispy_swig
from irispy_swig import inflate_region
import numpy as np

class IRISOptions(irispy_swig.IRISOptions):
    pass

class Ellipsoid(irispy_swig.Ellipsoid):
    pass

class IRISProblem(irispy_swig.IRISProblem):
    pass

class IRISRegion(irispy_swig.IRISRegion):
    pass

class Polyhedron(irispy_swig.Polyhedron):
    def printGenerators(self):
        print "printing generators from python"
        print self.generatorPoints()

    @staticmethod
    def fromBounds(lb, ub):
        lb = np.asarray(lb, dtype=np.float64)
        ub = np.asarray(ub, dtype=np.float64)
        p = Polyhedron()
        p.setA(np.vstack((np.eye(lb.size), -np.eye(lb.size))))
        p.setB(np.hstack((ub, -lb)))
        return p
