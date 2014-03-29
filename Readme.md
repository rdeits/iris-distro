Introduction
============

This package contains the IRIS algorithm for iterative convex regional
inflation by semidefinite programming, implemented in MATLAB. It is
designed to take an environment containing many (convex) obstacles and a
start point, and to compute a large convex obstacle-free region. This
region can then be used to define linear constraints for some other
objective function which the user might want to optimize over the
obstacle-free space. 

Setup
=====

The primary algorithm is distributed as:

	inflate_region.m


It requires both Gurobi and Mosek to be installed, and it additionally
relies on the implementation of the Lowner-John Inner ellipsoid function
provided by Mosek, which cannot be distributed here. That code can be
found at <http://docs.mosek.com/7.0/matlabfusion/Inner_and_outer_L_wner-John_Ellipsoids.html>

Due to MATLAB's package system, this repository must be cloned to a
folder named "+iris".  The algorithm can be demonstrated by adding the
folder containing the "+iris" directory, as well as the following
third-party folders:

	+iris/+thirdParty/polytopes
	+iris/+thirdParty/geom_3d/geom3d/geom3d

to the MATLAB path, then running:

	>>> import iris.test.*;
	>>> test_poly_2d;

Examples
========
Here are some animations of the algorithm running in various
environments:

![](rdeits.github.io/iris-distro/examples/poly_2d_N30/animation.gif)

![](rdeits.github.io/iris-distro/examples/poly_2d_N50/animation.gif)

![](rdeits.github.io/iris-distro/examples/poly_2d_N50_2/animation.gif)

![](rdeits.github.io/iris-distro/examples/poly_2d_N1000/animation.gif)

![](rdeits.github.io/iris-distro/examples/poly_3d/animation.gif)

![](rdeits.github.io/iris-distro/examples/poly_3d_2/animation.gif)

![](rdeits.github.io/iris-distro/examples/c_space_3d/animation.gif)

![](rdeits.github.io/iris-distro/examples/poly_4d/animation.gif)

