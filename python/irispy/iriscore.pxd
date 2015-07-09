from eigen cimport VectorXd, MatrixXd
from libcpp.vector cimport vector

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
		void initNSphere(VectorXd &point)
		void initNSphere(VectorXd &point, double radius)

	cdef cppclass CIRISRegion "IRISRegion":
		CIRISRegion(int dim) except +
		CPolytope polytope
		CEllipsoid ellipsoid

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

	cdef void inflate_region(const CIRISProblem &problem, const CIRISOptions &options, CIRISRegion *result)

	cdef const double ELLIPSOID_C_EPSILON

cdef extern from "iris/iris_utils.hpp":
	cdef MatrixXd copyToMatrix(double *data, int rows, int cols)
	cdef VectorXd copyToVector(double *data, int size)
