from eigen cimport VectorXd, MatrixXd

cdef extern from "iris/iris_types.hpp":
	cdef cppclass CPolytope "Polytope":
		CPolytope() except +
		int getDimension()
		int getNumberOfConstraints()
		void setA(MatrixXd A_)
		# void setA(double *A_, int rows, int cols)
		# void setB(double *b_, int rows)
		void setB(VectorXd b_)
		const MatrixXd& getA()
		const VectorXd& getB()
		void appendConstraints(const CPolytope &other)


	cdef cppclass CEllipsoid "Ellipsoid":
		CEllipsoid() except +
		int getDimension()
		void setC(MatrixXd &C)
		void setD(VectorXd &d)
		const MatrixXd& getC()
		const VectorXd& getD()
		@staticmethod
		CEllipsoid fromNSphere(VectorXd center)

cdef extern from "iris/iris_utils.hpp":
	cdef MatrixXd copyToMatrix(double *data, int rows, int cols)
	cdef VectorXd copyToVector(double *data, int size)
