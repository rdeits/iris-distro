Introduction
============

This package contains the IRIS algorithm for iterative convex regional
inflation by semidefinite programming, implemented in MATLAB. It is
designed to take an environment containing many (convex) obstacles and a
start point, and to compute a large convex obstacle-free region. This
region can then be used to define linear constraints for some other
objective function which the user might want to optimize over the
obstacle-free space. The algorithm is described in:

R.&nbsp;L.&nbsp;H. Deits and R.&nbsp;Tedrake, &ldquo;Computing large convex regions of
  obstacle-free space through semidefinite programming,&rdquo; Submitted
  to: <em>Workshop on the Algorithmic Fundamentals of Robotics</em>, Aug. 2014.
  [Online]. Available:
  <a href='http://groups.csail.mit.edu/robotics-center/public_papers/Deits14.pdf'>http://groups.csail.mit.edu/robotics-center/public_papers/Deits14.pdf</a>

Setup
=====

The primary algorithm is distributed as:

	inflate_region.m


It requires both Gurobi and Mosek (with Mosek Fusion) to be installed. Installing Mosek Fusion involves adding a `.jar` file to your Matlab javaclasspath. I put the following into my `startup.m` file (you can find this file by typing `edit startup` at the Matlab console):

	javaaddpath('/Users/rdeits/locomotion/lib/mosek/7/tools/platform/osx64x86/bin/mosekmatlab.jar');

The code is distributed as a MATLAB package, so only the root directory (the one that contains the "+iris" folder) needs to be added to your MATLAB path. You should be able to test it by running:

	>>> import iris.test.*;
	>>> test_poly_2d;

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

