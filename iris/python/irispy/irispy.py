from iris_wrapper import IRISOptions, IRISRegion, IRISProblem, IRISDebugData, Ellipsoid, Polyhedron
from iris_wrapper import inflate_region as c_inflate_region
import drawing

import itertools
import numpy as np
import matplotlib.pyplot as plt
import mpl_toolkits.mplot3d as a3
import matplotlib.animation as animation


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

def Polyhedron_fromBounds(lb, ub):
    lb = np.asarray(lb, dtype=np.float64)
    ub = np.asarray(ub, dtype=np.float64)
    p = Polyhedron()
    p.setA(np.vstack((np.eye(lb.size), -np.eye(lb.size))))
    p.setB(np.hstack((ub, -lb)))
    return p
setattr(Polyhedron, "fromBounds", staticmethod(Polyhedron_fromBounds))
setattr(Polyhedron, "from_bounds", staticmethod(Polyhedron_fromBounds))

def Polyhedron_getDrawingVertices(self):
    return np.hstack(self.generatorPoints()).T
setattr(Polyhedron, "getDrawingVertices", Polyhedron_getDrawingVertices)

def inflate_region(obstacles,
                   start_point_or_ellipsoid,
                   bounds=None,
                   require_containment=False,
                   required_containment_points=[],
                   error_on_infeasible_start=False,
                   termination_threshold=2e-2,
                   iter_limit=100,
                   return_debug_data=False):
    if not isinstance(start_point_or_ellipsoid, Ellipsoid):
        # Assume it's a starting point instead

        seed_ellipsoid = Ellipsoid.fromNSphere(start_point_or_ellipsoid)
    else:
        seed_ellipsoid = start_point_or_ellipsoid

    dim = seed_ellipsoid.getDimension()
    problem = IRISProblem(dim)
    problem.setSeedEllipsoid(seed_ellipsoid)

    for obs in obstacles:
        problem.addObstacle(obs)

    if bounds is not None:
        problem.setBounds(bounds)

    options = IRISOptions()
    options.require_containment = require_containment
    options.required_containment_points = required_containment_points
    options.error_on_infeasible_start = error_on_infeasible_start
    options.termination_threshold = termination_threshold
    options.iter_limit = iter_limit

    if return_debug_data:
        debug = IRISDebugData()
        region = c_inflate_region(problem, options, debug)
        return region, debug
    else:
        region = c_inflate_region(problem, options)
        return region

def IRISDebugData_iterRegions(self):
    return itertools.izip(self.polyhedron_history, self.ellipsoid_history)
setattr(IRISDebugData, "iterRegions", IRISDebugData_iterRegions)

def IRISDebugData_animate(self, fig=None, pause=0.5, show=True, repeat_delay=2.0):
    dim = self.bounds.getDimension()
    if dim < 2 or dim > 3:
        raise NotImplementedError("animation is not implemented for dimension < 2 or > 3")
    if fig is None:
        fig = plt.figure()
        if dim == 3:
            ax = a3.Axes3D(fig)
        else:
            ax = plt.gca()

    bounding_pts = np.hstack(self.boundingPoints()).T
    if bounding_pts.size > 0:
        lb = bounding_pts.min(axis=0)
        ub = bounding_pts.max(axis=0)
        assert(lb.size == dim)
        assert(ub.size == dim)
        width = ub - lb
        ax.set_xlim(lb[0] - 0.1 * width[0], ub[0] + 0.1 * width[0])
        ax.set_ylim(lb[1] - 0.1 * width[1], ub[1] + 0.1 * width[1])
        if dim == 3:
            ax.set_zlim(lb[2] - 0.1 * width[2], ub[2] + 0.1 * width[2])

    artist_sets = []
    for poly, ellipsoid in self.iterRegions():
        artists = []
        d = self.ellipsoid_history[0].getD()
        if dim == 3:
            artists.extend(ax.plot([d[0]], [d[1]], 'go', zs=[d[2]], markersize=10))
        else:
            artists.extend(ax.plot([d[0]], [d[1]], 'go', markersize=10))
        artists.extend(poly.draw(ax))
        artists.extend(ellipsoid.draw(ax))
        for obs in self.getObstacles():
            artists.extend(drawing.draw_convhull(obs.T, ax, edgecolor='k', facecolor='k', alpha=0.5))
        artist_sets.append(tuple(artists))

    ani = animation.ArtistAnimation(fig, artist_sets, interval=pause*1000, repeat_delay=repeat_delay*1000)
    if show:
        plt.show()
setattr(IRISDebugData, "animate", IRISDebugData_animate)






