# import both numpy and the Cython declarations for numpy
import numpy as np
cimport numpy as np
from cython.view cimport array as cvarray
from cython.operator cimport dereference as deref

cdef extern from "Eigen/Core" namespace "Eigen":
	cdef cppclass VectorXd:
		double* data()
	cdef cppclass MatrixXd:
		double* data()
	cdef cppclass Map[T]:
		Map(double *ptr, int rows, int cols)

cdef extern from "iris/iris.hpp":
	cdef cppclass CPolytope "Polytope":
		CPolytope() except +
		int getDimension()
		int getNumberOfConstraints()
		void setA(double *A_, int rows, int cols)
		void setB(double *b_, int rows)
		void setB(VectorXd b)
		const MatrixXd& getA()
		const VectorXd& getB()
		void appendConstraints(const CPolytope &other)


	cdef cppclass CEllipsoid "Ellipsoid":
		CEllipsoid() except +
		int getDimension()

cdef class Polytope:
	cdef CPolytope cpolytope 
	def getDimension(self):
		return self.cpolytope.getDimension()
	def setA(self, np.ndarray[double, ndim=2, mode="c"] A not None):
		# cdef Map[MatrixXd] *A_map = new Map[MatrixXd](&A[0,0], A.shape[0], A.shape[1])
		# self.cpolytope.setA(deref(A_map))
		# del A_map
		self.cpolytope.setA(&A[0,0], A.shape[0], A.shape[1])
	def getA(self):
		cdef cvarray = <double[:self.cpolytope.getNumberOfConstraints(),:self.cpolytope.getDimension()]> <double*> self.cpolytope.getA().data()
		return np.asarray(cvarray).copy()
	def setB(self, np.ndarray[double, ndim=1, mode="c"] b not None):
		self.cpolytope.setB(&b[0], b.shape[0])
	def getB(self):
		cdef cvarray = <double[:self.cpolytope.getNumberOfConstraints()]> <double*> self.cpolytope.getB().data()
		return np.asarray(cvarray).copy()
	def appendConstraints(self, Polytope other):
		self.cpolytope.appendConstraints(other.cpolytope)

