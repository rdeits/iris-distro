cdef extern from "iris/iris.hpp":
	cdef cppclass Polytope:
		Polytope(int) except +
		int getDimension()

cdef class PyPolytope:
	cdef Polytope *thisptr
	def __cinit__(self, int dim):
		self.thisptr = new Polytope(dim)
	def __dealloc__(self):
		del self.thisptr
	def getDimension(self):
		return self.thisptr.getDimension()

