# import both numpy and the Cython declarations for numpy
import numpy as np
cimport numpy as np
from cython.view cimport array as cvarray
from cython.operator cimport dereference as deref
from iriscore cimport CPolytope, CEllipsoid

cdef eigenMatrixToNumpy(const MatrixXd &M):
    cdef cvarray = <double[:M.rows(),:M.cols()]> <double*> M.data()
    return np.asarray(cvarray)

cdef eigenVectorToNumpy(const VectorXd &v):
    cdef cvarray = <double[:v.size()]> <double*> v.data()
    return np.asarray(cvarray)

cdef class Polytope:
    cdef CPolytope *thisptr
    cdef public bint owns_thisptr
    child_wrappers = []
    def __cinit__(self, dim=0, construct_new_cpp_object=True):
        if construct_new_cpp_object:
            self.thisptr = new CPolytope(dim)
            self.owns_thisptr = True
        else:
            self.owns_thisptr = False
    @staticmethod
    cdef wrap(CPolytope *cpolytope):
        pypolytope = Polytope(construct_new_cpp_object=False)
        pypolytope.thisptr = cpolytope
        return pypolytope

    def getDimension(self):
        return self.thisptr.getDimension()
    def setA(self, np.ndarray[double, ndim=2, mode="c"] A not None):
        cdef MatrixXd A_mat = copyToMatrix(&A[0,0], A.shape[0], A.shape[1])
        self.thisptr.setA(A_mat)
    def getA(self):
        return eigenMatrixToNumpy(self.thisptr.getA()).copy()
    def setB(self, np.ndarray[double, ndim=1, mode="c"] b not None):
        cdef VectorXd b_vec = copyToVector(&b[0], b.shape[0])
        self.thisptr.setB(b_vec)
    def getB(self):
        return eigenVectorToNumpy(self.thisptr.getB()).copy()
    def appendConstraints(self, Polytope other):
        self.thisptr.appendConstraints(deref(other.thisptr))
    def __dealloc__(self):
        for child in self.child_wrappers:
            child.owns_thisptr = True
        if self.owns_thisptr:
            del self.thisptr

cdef class Ellipsoid:
    cdef CEllipsoid *thisptr
    cdef public bint owns_thisptr
    child_wrappers = []
    def __cinit__(self, dim=0, construct_new_cpp_object=True):
        if construct_new_cpp_object:
            self.thisptr = new CEllipsoid(dim)
            self.owns_thisptr = True
        else:
            self.owns_thisptr = False
    @staticmethod
    cdef wrap(CEllipsoid *cellipsoid, is_owner=False):
        wrapper = Ellipsoid(construct_new_cpp_object=False)
        wrapper.thisptr = cellipsoid
        wrapper.owns_thisptr = is_owner
        return wrapper

    @staticmethod
    def fromNSphere(np.ndarray[double, ndim=1, mode="c"] d not None, double radius=ELLIPSOID_C_EPSILON):
        cdef int dim = d.shape[0]
        cdef VectorXd d_vec = copyToVector(&d[0], d.shape[0])
        ell = Ellipsoid(dim=dim)
        ell.thisptr.initNSphere(d_vec, radius)
        return ell

    def getDimension(self):
        return self.thisptr.getDimension()
    def setC(self, np.ndarray[double, ndim=2, mode="c"] C not None):
        cdef MatrixXd C_mat = copyToMatrix(&C[0,0], C.shape[0], C.shape[1])
        self.thisptr.setC(C_mat)
    def getC(self):
        return eigenMatrixToNumpy(self.thisptr.getC()).copy()
    def setD(self, np.ndarray[double, ndim=1, mode="c"] d not None):
        cdef VectorXd d_vec = copyToVector(&d[0], d.shape[0])
        self.thisptr.setD(d_vec)
    def getD(self):
        return eigenVectorToNumpy(self.thisptr.getD()).copy()
    def __dealloc__(self):
        for child in self.child_wrappers:
            child.owns_thisptr = True
        if self.owns_thisptr:
            del self.thisptr

cdef class IRISRegion:
    cdef CIRISRegion *thisptr
    cdef public bint owns_thisptr
    child_wrappers = []
    cdef public Polytope polytope
    cdef public Ellipsoid ellipsoid
    def __cinit__(self, construct_new_cpp_object=True, dim=0):
        if construct_new_cpp_object:
            self.thisptr = new CIRISRegion(dim)
            self.owns_thisptr = True
            self.polytope = Polytope.wrap(&self.thisptr.polytope)
            self.ellipsoid = Ellipsoid.wrap(&self.thisptr.ellipsoid)
            self.child_wrappers.extend([self.polytope, self.ellipsoid])
        else:
            self.owns_thisptr = False
    @staticmethod
    cdef wrap(CIRISRegion *cregion):
        pyregion = IRISRegion(construct_new_cpp_object=False, dim=cregion.polytope.getDimension())
        pyregion.thisptr = cregion
        pyregion.polytope = Polytope.wrap(&pyregion.thisptr.polytope)
        pyregion.ellipsoid = Ellipsoid.wrap(&pyregion.thisptr.ellipsoid)
        pyregion.child_wrappers.extend([pyregion.polytope, pyregion.ellipsoid])
        return pyregion

    def __dealloc__(self):
        for child in self.child_wrappers:
            child.owns_thisptr = True
        if self.owns_thisptr:
            del self.thisptr

def run_iris(obstacles, Ellipsoid start, Polytope bounds=None,  
                  require_containment=False,
                  error_on_infeasible_start=False, 
                  termination_threshold=2e-2, 
                  iter_limit = 100):
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
        region = IRISRegion(dim=dim)
        inflate_region(deref(problem), options, region.thisptr)
    finally:
        del problem
    return region