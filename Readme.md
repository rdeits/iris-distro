Introduction
============

This package contains the IRIS algorithm for iterative convex regional inflation by semidefinite programming, implemented in MATLAB and Python. It is designed to take an environment containing many (convex) obstacles and a start point, and to compute a large convex obstacle-free region. This region can then be used to define linear constraints for some other objective function which the user might want to optimize over the obstacle-free space. The algorithm is described in:

R.&nbsp;L.&nbsp;H. Deits and R.&nbsp;Tedrake, &ldquo;Computing large convex regions of
  obstacle-free space through semidefinite programming,&rdquo; Submitted
  to: <em>Workshop on the Algorithmic Fundamentals of Robotics</em>, Aug. 2014.
  [Online]. Available:
  <a href='http://groups.csail.mit.edu/robotics-center/public_papers/Deits14.pdf'>http://groups.csail.mit.edu/robotics-center/public_papers/Deits14.pdf</a>

Setup
=====

The primary algorithm is distributed as:

	inflate_region.m

You'll need to build a few tools first, and in order to do so, you'll need to make sure that the `matlab` executable is on your system path. The `matlab` executable lives in `/Applications/MATLAB_R2014b.app/bin/` or similar on OSX and `/usr/local/MATLAB/R2014a/bin/` on linux. You can either add that folder to your system PATH variable put a symbolic link to the `matlab` executable somewhere that is already on your path, like `/usr/local/bin`.

To build IRIS, just `cd` into the IRIS folder and run:

	make

Pods Compatibility
------------------

This software is designed to be compatible with the Pods guidelines: <http://sourceforge.net/p/pods/home/Home/>. If that means nothing to you, don't worry about it: just make sure the `matlab` folder is on your MATLAB path and/or the `python` folder is on your `PYTHONPATH`. If you are familiar with Pods, then you can also use the wrapper pods provided by the RobotLocomotion group to satisfy the Gurobi and Mosek dependencies (licenses for both must be acquired separately).

* Gurobi: <https://github.com/RobotLocomotion/gurobi>
* Mosek: <https://github.com/RobotLocomotion/mosek>

External Requirements
---------------------

The MATLAB implementation requires the Mosek toolbox for MATLAB, and the Python implementation currently requires both Mosek and Gurobi. You can either download those tools manually or use our wrapper pods mentioned above. If you manually install Mosek, please make sure to also set up the Mosek Fusion tool for MATLAB. Fusion provides a Java API, so you'll need to add `mosekmatlab.jar` to MATLAB's Java path. Instructions for that are here: <http://docs.mosek.com/7.1/matlabfusion/Introduction.html#sec:tut:basic_ex>

Installing and Running IRIS in MATLAB
-------------------------------------

The code is distributed as a MATLAB package, so only the `matlab` directory (the one that contains the "+iris" folder) needs to be added to your MATLAB path. You should be able to test it by running (in MATLAB):

	>>> import iris.test.*;
	>>> test_poly_2d;


Python Implementation
---------------------

An experimental Python implementation of the base algorithm is also provided in `python/irispy`. You can see a demonstration of its operation in irispy_exploration.ipynb (an IPython notebook), which can also be viewed online through [nbviewer](http://nbviewer.ipython.org/urls/raw.githubusercontent.com/rdeits/iris-distro/master/python/irispy_exploration.ipynb)

Python Requirements
-------------------

To run the Python implementation, you will need at least:

	* numpy
	* scipy
	* PyPolyhedron: http://cens.ioc.ee/projects/polyhedron/

Examples
========
Here are some animations of the algorithm running in various
environments:

2-dimensional space, 30 obstacles:

![](https://rdeits.github.io/iris-distro/examples/poly_2d_N30/animation.gif)

2-dimensional space, 50 obstacles:

![](https://rdeits.github.io/iris-distro/examples/poly_2d_N50/animation.gif)

2-dimensional space, 50 obstacles:

![](https://rdeits.github.io/iris-distro/examples/poly_2d_N50_2/animation.gif)

2-dimensional space, 1000 obstacles:

![](https://rdeits.github.io/iris-distro/examples/poly_2d_N1000/animation.gif)

3-dimensional space:

![](https://rdeits.github.io/iris-distro/examples/poly_3d/animation.gif)

3-dimensional space:

![](https://rdeits.github.io/iris-distro/examples/poly_3d_2/animation.gif)

3-dimensional configuration space of a rod-shaped robot translating and yawing:

![](https://rdeits.github.io/iris-distro/examples/c_space_3d/animation.gif)

3-dimensional slice of a 4-dimensional region among 4D obstacles:

![](https://rdeits.github.io/iris-distro/examples/poly_4d/animation.gif)

Example Application
===================
This is a demonstration of path-planning for a simple UAV model around obstacles. Rather than constraining that the UAV be outside the obstacles, we seed several IRIS regions and require that the UAV be inside one of those regions at each time step. This turns a non-convex problem into a mixed-integer convex problem, which we can solve to its global optimum. You can try this out by running `iris.test.test_uav_demo();` or `iris.test.test_uav_demo('4d');`

![](http://rdeits.github.io/iris-distro/examples/uav/demo_uav.png)
