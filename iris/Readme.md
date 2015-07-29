Introduction
============

This package contains the IRIS algorithm for iterative convex regional inflation by semidefinite programming, implemented in C++ with bindings for MATLAB and Python. It is designed to take an environment containing many (convex) obstacles and a start point, and to compute a large convex obstacle-free region. This region can then be used to define linear constraints for some other objective function which the user might want to optimize over the obstacle-free space. The algorithm is described in:

R.&nbsp;L.&nbsp;H. Deits and R.&nbsp;Tedrake, &ldquo;Computing large convex regions of
  obstacle-free space through semidefinite programming,&rdquo; Submitted
  to: <em>Workshop on the Algorithmic Fundamentals of Robotics</em>, Aug. 2014.
  [Online]. Available:
  <a href='http://groups.csail.mit.edu/robotics-center/public_papers/Deits14.pdf'>http://groups.csail.mit.edu/robotics-center/public_papers/Deits14.pdf</a>

This project is distributed in accordance with the Pods guidelines: <http://sourceforge.net/p/pods/home/Home/>. If you've used pods before, then it should be easy to integrate IRIS along with your other Pods projects. If not, then check out <https://github.com/rdeits/iris-distro> for more information.

This package contains the IRIS algorithm and its MATLAB and Python bindings, but it doesn't include the additional tools you'll need like Mosek, Eigen, and cddlib. You can find all of those, plus more detailed installation instructions, here: <https://github.com/rdeits/iris-distro>

Example Usage
=============

Python wrapper
--------------

    python -m irispy.test.test_iris_2d

Matlab wrapper
--------------

    >>> addpath_iris
    >>> iris.test.test_poly_2d();

C++ library
-----------

See `src/iris_demo.cpp` for a basic usage example.

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
