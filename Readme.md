This package contains the IRIS algorithm for iterative convex regional inflation by semidefinite programming, implemented in MATLAB. It is designed to take an environment containing many (convex) obstacles and a start point, and to compute a large convex obstacle-free region. This region can then be used to define linear constraints for some other objective function which the user might want to optimize over the obstacle-free space. 

It requires both Gurobi and Mosek to be installed, and it additionally
relies on the implementation of the Lowner-John Inner ellipsoid function
provided by Mosek, which cannot be distributed here. That code can be
found at <http://docs.mosek.com/7.0/matlabfusion/Inner_and_outer_L_wner-John_Ellipsoids.html>

The algorithm can be demonstrated by adding the folder containing the
"+iris" directory, as well as the following third-party folders:

	+iris/+thirdParty/polytopes
	+iris/+thirdParty/geom_3d/geom3d/geom3d

to the MATLAB path, then running:

	>>> import iris.test.*;
	>>> test_poly_2d;
