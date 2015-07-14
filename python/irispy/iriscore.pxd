from eigen cimport VectorXd, MatrixXd
# from libcpp.memory cimport shared_ptr
from libcpp.vector cimport vector

cdef extern from "<memory>" namespace "std":
	cdef cppclass shared_ptr[T]:
		shared_ptr()
		shared_ptr(T *p)
		shared_ptr(const shared_ptr&)
		reset(T *p)
		T operator*()
		T *get()

cdef extern from "iris/iris.hpp":
	cdef cppclass CPolytope "Polytope":
		CPolytope() except +
		CPolytope(int dim) except +
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
		CEllipsoid(int dim) except +
		int getDimension()
		void setC(MatrixXd &C)
		void setD(VectorXd &d)
		const MatrixXd& getC()
		const VectorXd& getD()
		@staticmethod
		shared_ptr[CEllipsoid] fromNSphere(VectorXd &point)
		@staticmethod
		shared_ptr[CEllipsoid] fromNSphere(VectorXd &point, double radius)

	cdef cppclass CIRISRegion "IRISRegion":
		CIRISRegion(int dim) except +
		shared_ptr[CPolytope] polytope
		shared_ptr[CEllipsoid] ellipsoid

	cdef cppclass CIRISProblem "IRISProblem":
		CIRISProblem(int dim) except +
		void setSeedPoint(VectorXd point)
		void setSeedEllipsoid(CEllipsoid ellipsoid)
		int getDimension()
		CEllipsoid getSeed()
		void setBounds(CPolytope bounds)
		void addObstacle(MatrixXd new_obstacle_vertices)
		vector[MatrixXd] getObstacles()
		CPolytope getBounds()

	cdef cppclass CIRISOptions "IRISOptions":
		bint require_containment, error_on_infeasible_start
		double termination_threshold
		int iter_limit

	cdef shared_ptr[CIRISRegion] inflate_region(const CIRISProblem &problem, const CIRISOptions &options)

	cdef const double ELLIPSOID_C_EPSILON

cdef extern from "iris/iris_utils.hpp":
	cdef MatrixXd copyToMatrix(double *data, int rows, int cols)
	cdef VectorXd copyToVector(double *data, int size)
