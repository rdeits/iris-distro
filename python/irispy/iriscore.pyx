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
    cdef CPolytope cpolytope 
    def getDimension(self):
        return self.cpolytope.getDimension()
    def setA(self, np.ndarray[double, ndim=2, mode="c"] A not None):
        cdef MatrixXd A_mat = copyToMatrix(&A[0,0], A.shape[0], A.shape[1])
        self.cpolytope.setA(A_mat)
    def getA(self):
        return eigenMatrixToNumpy(self.cpolytope.getA()).copy()
    def setB(self, np.ndarray[double, ndim=1, mode="c"] b not None):
        cdef VectorXd b_vec = copyToVector(&b[0], b.shape[0])
        self.cpolytope.setB(b_vec)
    def getB(self):
        return eigenVectorToNumpy(self.cpolytope.getB()).copy()
    def appendConstraints(self, Polytope other):
        self.cpolytope.appendConstraints(other.cpolytope)

cdef class Ellipsoid:
    cdef CEllipsoid cellipsoid
    def getDimension(self):
        return self.cellipsoid.getDimension()
    def setC(self, np.ndarray[double, ndim=2, mode="c"] C not None):
        cdef MatrixXd C_mat = copyToMatrix(&C[0,0], C.shape[0], C.shape[1])
        self.cellipsoid.setC(C_mat)
    def getC(self):
        return eigenMatrixToNumpy(self.cellipsoid.getC()).copy()
    def setD(self, np.ndarray[double, ndim=1, mode="c"] d not None):
        cdef VectorXd d_vec = copyToVector(&d[0], d.shape[0])
        self.cellipsoid.setD(d_vec)
    def getD(self):
        return eigenVectorToNumpy(self.cellipsoid.getD()).copy()
