# import both numpy and the Cython declarations for numpy
import numpy as np
cimport numpy as np
from cython.view cimport array as cvarray
from cython.operator cimport dereference as deref
from iriscore cimport inflate_region as cinflate_region

cdef eigenMatrixToNumpy(const MatrixXd &M):
    cdef cvarray = <double[:M.rows(),:M.cols()]> <double*> M.data()
    return np.asarray(cvarray).copy()

cdef eigenVectorToNumpy(const VectorXd &v):
    cdef cvarray = <double[:v.size()]> <double*> v.data()
    return np.asarray(cvarray).copy()

cdef class Polytope:
    cdef shared_ptr[CPolytope] thisptr
    def __cinit__(self, dim=0, construct_new_cpp_object=True):
        if construct_new_cpp_object:
            self.thisptr = shared_ptr[CPolytope](new CPolytope(dim))
    @staticmethod
    cdef wrap(shared_ptr[CPolytope] ptr):
        pyobj = Polytope(construct_new_cpp_object=False)
        pyobj.thisptr = ptr
        return pyobj

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
    def appendConstraints(self, Polytope other):
        self.thisptr.get().appendConstraints(deref(other.thisptr))
    def generatorPoints(self):
        cdef vector[VectorXd] pts = self.thisptr.get().generatorPoints()
        return [eigenVectorToNumpy(pt) for pt in pts]
    def generatorRays(self):
        cdef vector[VectorXd] pts = self.thisptr.get().generatorRays()
        return [eigenVectorToNumpy(pt) for pt in pts]

cdef class Ellipsoid:
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

cdef class IRISRegion:
    cdef shared_ptr[CIRISRegion] thisptr
    def __cinit__(self, dim=0, construct_new_cpp_object=True):
        if construct_new_cpp_object:
            self.thisptr = shared_ptr[CIRISRegion](new CIRISRegion(dim))
    @staticmethod
    cdef wrap(shared_ptr[CIRISRegion] ptr):
        pyobj = IRISRegion(dim=ptr.get().polytope.get().getDimension(), construct_new_cpp_object=False)
        pyobj.thisptr = ptr
        return pyobj

    def getPolytope(self):
        return Polytope.wrap(self.thisptr.get().polytope)

    def getEllipsoid(self):
        return Ellipsoid.wrap(self.thisptr.get().ellipsoid)

def inflate_region(obstacles, start_point_or_ellipsoid, Polytope bounds=None,
                  require_containment=False,
                  error_on_infeasible_start=False,
                  termination_threshold=2e-2,
                  iter_limit = 100):

    cdef Ellipsoid start
    if isinstance(start_point_or_ellipsoid, Ellipsoid):
        start = start_point_or_ellipsoid
    else:
        start = Ellipsoid.fromNSphere(start_point_or_ellipsoid)

    cdef int dim = start.getDimension()
    cdef CIRISProblem *problem = new CIRISProblem(dim)

    if bounds is None:
        bounds = Polytope(dim)
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
        region = IRISRegion.wrap(cinflate_region(deref(problem), options))
    finally:
        del problem
    return region