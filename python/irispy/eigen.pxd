cdef extern from "Eigen/Core" namespace "Eigen":
	cdef cppclass VectorXd:
		double* data()
		int size()
	cdef cppclass MatrixXd:
		double* data()
		int rows()
		int cols()
