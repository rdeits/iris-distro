import itertools
import time
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation
from matplotlib.colors import colorConverter
import mpl_toolkits.mplot3d as a3
import scipy.spatial
cimport numpy as np
from cython.view cimport array as cvarray
from cython.operator cimport dereference as deref
from iriscore cimport inflate_region as cinflate_region

cdef eigenMatrixToNumpy(const MatrixXd &M):
    cdef cvarray = <double[:M.rows():1,:M.cols()]> <double*> M.data()
    return np.asarray(cvarray, order='F').copy()

cdef eigenVectorToNumpy(const VectorXd &v):
    cdef cvarray = <double[:v.size()]> <double*> v.data()
    return np.asarray(cvarray, order='F').copy()

cdef class DrawDispatcher:
    def draw(self, ax=None, **kwargs):
        if self.getDimension() == 2:
            return self.draw2d(ax=ax, **kwargs)
        elif self.getDimension() == 3:
            return self.draw3d(ax=ax, **kwargs)
        else:
            raise NotImplementedError("drawing for objects of dimension greater than 3 not implemented yet")

def draw_3d_convhull(points, ax, **kwargs):
    kwargs.setdefault("edgecolor", "k")
    kwargs.setdefault("facecolor", "r")
    kwargs.setdefault("alpha", 0.5)
    kwargs["facecolor"] = colorConverter.to_rgba(kwargs["facecolor"], kwargs["alpha"])
    hull = scipy.spatial.ConvexHull(points)
    artists = []
    for simplex in hull.simplices:
        poly = a3.art3d.Poly3DCollection([points[simplex]], **kwargs)
        if "alpha" in kwargs:
            poly.set_alpha(kwargs["alpha"])
        ax.add_collection3d(poly)
        artists.append(poly)
    return artists

cdef class Polyhedron(DrawDispatcher):
    cdef shared_ptr[CPolyhedron] thisptr
    def __cinit__(self, dim=0, construct_new_cpp_object=True):
        if construct_new_cpp_object:
            self.thisptr = shared_ptr[CPolyhedron](new CPolyhedron(dim))
    @staticmethod
    cdef wrap(shared_ptr[CPolyhedron] ptr):
        pyobj = Polyhedron(construct_new_cpp_object=False)
        pyobj.thisptr = ptr
        return pyobj
    @staticmethod
    def from_bounds(lower_bound, upper_bound):
        lower_bound = np.asarray(lower_bound, dtype=np.float64)
        upper_bound= np.asarray(upper_bound, dtype=np.float64)
        assert(lower_bound.size == upper_bound.size)
        assert(len(lower_bound.shape) == 1)
        assert(len(upper_bound.shape) == 1)
        dim = lower_bound.shape[0]
        A = np.vstack((np.eye(dim), -np.eye(dim)))
        b = np.hstack((upper_bound, -lower_bound))
        poly = Polyhedron(dim)
        poly.setA(A)
        poly.setB(b)
        return poly

    def getDimension(self):
        return self.thisptr.get().getDimension()
    def setA(self, np.ndarray[double, ndim=2, mode="c"] A not None):
        cdef MatrixXd A_mat = copyToMatrix(&A[0,0], A.shape[0], A.shape[1])
        self.thisptr.get().setA(A_mat)
    def getA(self):
        return eigenMatrixToNumpy(self.thisptr.get().getA())
    def setB(self, np.ndarray[double, ndim=1, mode="c"] b not None):
        cdef VectorXd b_vec = copyToVector(&b[0], b.shape[0])
        self.thisptr.get().setB(b_vec)
    def getB(self):
        return eigenVectorToNumpy(self.thisptr.get().getB())
    def appendConstraints(self, Polyhedron other):
        self.thisptr.get().appendConstraints(deref(other.thisptr))
    def generatorPoints(self):
        cdef vector[VectorXd] pts = self.thisptr.get().generatorPoints()
        return [eigenVectorToNumpy(pt) for pt in pts]
    def generatorRays(self):
        cdef vector[VectorXd] pts = self.thisptr.get().generatorRays()
        return [eigenVectorToNumpy(pt) for pt in pts]
    def draw2d(self, ax=None, **kwargs):
        if ax is None:
            ax = plt.gca()
        points = np.vstack(self.generatorPoints())
        hull = scipy.spatial.ConvexHull(points)
        kwargs.setdefault("edgecolor", "r")
        kwargs.setdefault("facecolor", "none")
        return [ax.add_patch(plt.Polygon(xy=points[hull.vertices],**kwargs))]
    def draw3d(self, ax=None, **kwargs):
        if ax is None:
            ax = a3.Axes3D(plt.gcf())
        points = np.vstack(self.generatorPoints())
        kwargs.setdefault("facecolor", "r")
        return draw_3d_convhull(points, ax, **kwargs)


cdef class Ellipsoid(DrawDispatcher):
    cdef shared_ptr[CEllipsoid] thisptr
    def __cinit__(self, dim=0, construct_new_cpp_object=True):
        if construct_new_cpp_object:
            self.thisptr = shared_ptr[CEllipsoid](new CEllipsoid(dim))
    @staticmethod
    cdef wrap(shared_ptr[CEllipsoid] ptr):
        pyobj = Ellipsoid(construct_new_cpp_object=False)
        pyobj.thisptr = ptr
        return pyobj
    @staticmethod
    def fromNSphere(center, double radius=ELLIPSOID_C_EPSILON):
        cdef np.ndarray[double, ndim=1, mode="c"] d = np.asarray(center, dtype=np.float64)
        cdef VectorXd d_vec = copyToVector(&d[0], d.shape[0])
        return Ellipsoid.wrap(CEllipsoid.fromNSphere(d_vec, radius))

    def getDimension(self):
        return self.thisptr.get().getDimension()
    def setC(self, np.ndarray[double, ndim=2, mode="c"] C not None):
        cdef MatrixXd C_mat = copyToMatrix(&C[0,0], C.shape[0], C.shape[1])
        self.thisptr.get().setC(C_mat)
    def getC(self):
        return eigenMatrixToNumpy(self.thisptr.get().getC())
    def setD(self, np.ndarray[double, ndim=1, mode="c"] d not None):
        cdef VectorXd d_vec = copyToVector(&d[0], d.shape[0])
        self.thisptr.get().setD(d_vec)
    def getD(self):
        return eigenVectorToNumpy(self.thisptr.get().getD())
    def getVolume(self):
        return self.thisptr.get().getVolume()
    def draw2d(self, ax=None, **kwargs):
        if ax is None:
            ax = plt.gca()
        theta = np.linspace(0, 2 * np.pi, 100)
        y = np.vstack((np.sin(theta), np.cos(theta)))
        points = (self.getC().dot(y) + self.getD()[:,np.newaxis]).T
        hull = scipy.spatial.ConvexHull(points)
        kwargs.setdefault("edgecolor", "b")
        kwargs.setdefault("facecolor", "none")
        kwargs.setdefault("linewidth", 1)
        return [ax.add_patch(plt.Polygon(xy=points[hull.vertices],**kwargs))]
    def draw3d(self, ax=None, **kwargs):
        if ax is None:
            ax = a3.Axes3D(plt.gcf())

        theta = np.linspace(0, 2 * np.pi, 20)
        y = np.vstack((np.sin(theta), np.cos(theta), np.zeros_like(theta)))
        for phi in np.linspace(0, np.pi, 10):
            R = np.array([[1.0, 0.0, 0.0],
                          [0.0, np.cos(phi), -np.sin(phi)],
                          [0.0, np.sin(phi), np.cos(phi)]])
            y = np.hstack((y, R.dot(y)))
        x = self.getC().dot(y) + self.getD()[:,np.newaxis]
        kwargs.setdefault("facecolor", "b")
        return draw_3d_convhull(x.T, ax, **kwargs)

cdef class IRISRegion:
    cdef shared_ptr[CIRISRegion] thisptr
    def __cinit__(self, dim=0, construct_new_cpp_object=True):
        if construct_new_cpp_object:
            self.thisptr = shared_ptr[CIRISRegion](new CIRISRegion(dim))
    @staticmethod
    cdef wrap(shared_ptr[CIRISRegion] ptr):
        pyobj = IRISRegion(dim=ptr.get().polyhedron.get().getDimension(), construct_new_cpp_object=False)
        pyobj.thisptr = ptr
        return pyobj

    def getPolyhedron(self):
        return Polyhedron.wrap(self.thisptr.get().polyhedron)

    def getEllipsoid(self):
        return Ellipsoid.wrap(self.thisptr.get().ellipsoid)

cdef class IRISDebugData:
    cdef shared_ptr[CIRISDebugData] thisptr
    def __cinit__(self, construct_new_cpp_object=True):
        if construct_new_cpp_object:
            self.thisptr = shared_ptr[CIRISDebugData](new CIRISDebugData());
    @staticmethod
    cdef wrap(shared_ptr[CIRISDebugData] ptr):
        pyobj = IRISDebugData(construct_new_cpp_object=False)
        pyobj.thisptr = ptr
        return pyobj
    def getNumberOfPolyhedrons(self):
        return self.thisptr.get().polyhedron_history.size()
    def getNumberOfEllipsoids(self):
        return self.thisptr.get().ellipsoid_history.size()
    def getPolyhedron(self, index=-1):
        if index < 0:
            index = self.getNumberOfPolyhedrons() + index
        if index >= self.getNumberOfPolyhedrons():
            raise IndexError("polyhedron index out of bounds")
        poly = Polyhedron(dim=self.thisptr.get().polyhedron_history[index].getDimension())
        poly.thisptr.get()[0] = self.thisptr.get().polyhedron_history[index]
        return poly
    def iterPolyhedrons(self):
        for i in xrange(self.getNumberOfPolyhedrons()):
            yield self.getPolyhedron(i)
    def getEllipsoid(self, index=-1):
        if index < 0:
            index = self.getNumberOfEllipsoids() + index
        if index >= self.getNumberOfEllipsoids():
            raise IndexError("ellipsoid index out of bounds")
        ellipsoid = Ellipsoid(dim=self.thisptr.get().ellipsoid_history[index].getDimension())
        ellipsoid.thisptr.get()[0] = self.thisptr.get().ellipsoid_history[index]
        return ellipsoid
    def iterEllipsoids(self):
        for i in xrange(self.getNumberOfEllipsoids()):
            yield self.getEllipsoid(i)
    def iterRegions(self):
        return itertools.izip(self.iterPolyhedrons(), self.iterEllipsoids())
    def iterObstacles(self):
        cdef vector[MatrixXd] obstacles = self.thisptr.get().obstacles
        return (eigenMatrixToNumpy(obs) for obs in obstacles)
    def boundingPoints(self):
        cdef vector[VectorXd] pts = self.thisptr.get().bounds.generatorPoints()
        return [eigenVectorToNumpy(pt) for pt in pts]
    def animate(self, *args, **kwargs):
        cdef int dim = self.thisptr.get().bounds.getDimension()
        if dim == 2:
            self.animate2d(*args, **kwargs)
        elif dim == 3:
            self.animate3d(*args, **kwargs)
        else:
            raise ValueError("not implemented for dimension > 3")

    def animate3d(self, fig=None, pause=0.5, show=True, repeat_delay=2.0): 
        if fig is None:
            fig = plt.figure()
            ax = a3.Axes3D(fig)
        bounding_pts = np.vstack(self.boundingPoints())
        lb = bounding_pts.min(axis=0)
        ub = bounding_pts.max(axis=0)
        width = ub - lb

        ax.set_xlim(lb[0] - 0.1 * width[0], ub[0] + 0.1 * width[0])
        ax.set_ylim(lb[1] - 0.1 * width[1], ub[1] + 0.1 * width[1])
        ax.set_zlim(lb[2] - 0.1 * width[2], ub[2] + 0.1 * width[2])

        artist_sets = []
        for poly, ellipsoid in self.iterRegions():
            # ax.cla()
            artists = []
            d = self.getEllipsoid(0).getD()
            artists.extend(ax.plot([d[0]], [d[1]], 'go', zs=[d[2]],  markersize=10))
            artists.extend(poly.draw(ax))
            artists.extend(ellipsoid.draw(ax))
            for obs in self.iterObstacles():
                artists.extend(draw_3d_convhull(obs.T, ax, edgecolor='k', facecolor='k', alpha=0.5))
            artist_sets.append(tuple(artists))

        ani = animation.ArtistAnimation(fig, artist_sets, interval=pause*1000, repeat_delay=repeat_delay*1000)
        if show:
            plt.show()


    def animate2d(self, fig=None, pause=0.5, show=True, repeat_delay=2.0):

        if fig is None:
            fig = plt.figure()
            ax = plt.gca()

        bounding_pts = np.vstack(self.boundingPoints())
        lb = bounding_pts.min(axis=0)
        ub = bounding_pts.max(axis=0)
        width = ub - lb

        ax.set_xlim(lb[0] - 0.1 * width[0], ub[0] + 0.1 * width[0])
        ax.set_ylim(lb[1] - 0.1 * width[1], ub[1] + 0.1 * width[1])

        artist_sets = []
        for poly, ellipsoid in self.iterRegions():
            # ax.cla()
            artists = []
            artists.extend(ax.plot([self.getEllipsoid(0).getD()[0]],
                    [self.getEllipsoid(0).getD()[1]],
                    'go', markersize=10))
            artists.extend(poly.draw(ax))
            artists.extend(ellipsoid.draw(ax))
            for obs in self.iterObstacles():
                points = obs.T
                hull = scipy.spatial.ConvexHull(points)
                artists.append(ax.add_patch(plt.Polygon(xy=points[hull.vertices],edgecolor='k', facecolor=colorConverter.to_rgba("k", 0.5))))
            artist_sets.append(tuple(artists))

        ani = animation.ArtistAnimation(fig, artist_sets, interval=pause*1000, repeat_delay=repeat_delay*1000)
        if show:
            plt.show()

def inflate_region(obstacles, start_point_or_ellipsoid, Polyhedron bounds=None,
                  require_containment=False,
                  error_on_infeasible_start=False,
                  termination_threshold=2e-2,
                  iter_limit = 100,
                  return_debug_data=False):

    cdef Ellipsoid start
    if isinstance(start_point_or_ellipsoid, Ellipsoid):
        start = start_point_or_ellipsoid
    else:
        start = Ellipsoid.fromNSphere(start_point_or_ellipsoid)

    cdef int dim = start.getDimension()
    cdef CIRISProblem *problem = new CIRISProblem(dim)

    if bounds is None:
        bounds = Polyhedron(dim)
    problem.setBounds(deref(bounds.thisptr))
    problem.setSeedEllipsoid(deref(start.thisptr))

    cdef CIRISOptions options
    options.require_containment = require_containment
    options.error_on_infeasible_start = error_on_infeasible_start
    options.termination_threshold = termination_threshold
    options.iter_limit = iter_limit
    cdef MatrixXd obs_mat
    cdef np.ndarray[double, ndim=2, mode="c"] obs
    try:
        for obs in obstacles:
            assert(obs.shape[0] == dim, "Obstacle points should be size dim x num_points")
            obs_mat = copyToMatrix(&obs[0,0], obs.shape[0], obs.shape[1])
            problem.addObstacle(obs_mat)
        if return_debug_data:
            debug = IRISDebugData()
            region = IRISRegion.wrap(cinflate_region(deref(problem), options, debug.thisptr.get()))
        else:
            region = IRISRegion.wrap(cinflate_region(deref(problem), options))
    except Exception as e:
        print e
    finally:
        del problem
    if return_debug_data:
        return region, debug
    else:
        return region