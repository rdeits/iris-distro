import iris_wrapper
from iris_wrapper import IRISOptions, IRISRegion, IRISProblem, Ellipsoid, Polyhedron, inflate_region
import drawing
import numpy as np


Ellipsoid.__bases__ += (drawing.DrawDispatcher,)
def Ellipsoid_getDrawingVertices(self):
    if self.getDimension() == 2:
        theta = np.linspace(0, 2 * np.pi, 100)
        y = np.vstack((np.sin(theta), np.cos(theta)))
        return (self.getC().dot(y) + self.getD()).T
    elif self.getDimension() == 3:
        theta = np.linspace(0, 2 * np.pi, 20)
        y = np.vstack((np.sin(theta), np.cos(theta), np.zeros_like(theta)))
        for phi in np.linspace(0, np.pi, 10):
            R = np.array([[1.0, 0.0, 0.0],
                          [0.0, np.cos(phi), -np.sin(phi)],
                          [0.0, np.sin(phi), np.cos(phi)]])
            y = np.hstack((y, R.dot(y)))
        x = self.getC().dot(y) + self.getD()
        return x.T
    else:
        raise NotImplementedError("Ellipsoid vertices not implemented for dimension < 2 or > 3")
setattr(Ellipsoid, "getDrawingVertices", Ellipsoid_getDrawingVertices)
setattr(Ellipsoid, "default_color", "b")


Polyhedron.__bases__ += (drawing.DrawDispatcher,)
def Polyhedron_printGenerators(self):
    print "printing generators from python"
    print self.generatorPoints()
setattr(Polyhedron, "printGenerators", Polyhedron_printGenerators)

def Polyhedron_fromBounds(lb, ub):
    lb = np.asarray(lb, dtype=np.float64)
    ub = np.asarray(ub, dtype=np.float64)
    p = Polyhedron()
    p.setA(np.vstack((np.eye(lb.size), -np.eye(lb.size))))
    p.setB(np.hstack((ub, -lb)))
    return p
setattr(Polyhedron, "fromBounds", staticmethod(Polyhedron_fromBounds))

def Polyhedron_getDrawingVertices(self):
    return np.hstack(self.generatorPoints()).T
setattr(Polyhedron, "getDrawingVertices", Polyhedron_getDrawingVertices)


# def inflate_region(*args, **kwargs):
#     cpp_region = iris_wrapper.inflate_region(*args, **kwargs)
#     print cpp_region
#     region = IRISRegion(cpp_region.getPolyhedron().getDimension())
#     region.this = cpp_region.this
#     region.thisown = cpp_region.thisown
#     return region