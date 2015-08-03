Introduction
============

This package contains the IRIS algorithm for iterative convex regional inflation by semidefinite programming, implemented in C++ with bindings for MATLAB and Python. It is designed to take an environment containing many (convex) obstacles and a start point, and to compute a large convex obstacle-free region. This region can then be used to define linear constraints for some other objective function which the user might want to optimize over the obstacle-free space. The algorithm is described in:

R.&nbsp;L.&nbsp;H. Deits and R.&nbsp;Tedrake, &ldquo;Computing large convex regions of
  obstacle-free space through semidefinite programming,&rdquo; Submitted
  to: <em>Workshop on the Algorithmic Fundamentals of Robotics</em>, Aug. 2014.
  [Online]. Available:
  <a href='http://groups.csail.mit.edu/robotics-center/public_papers/Deits14.pdf'>http://groups.csail.mit.edu/robotics-center/public_papers/Deits14.pdf</a>

[![Build Status](https://travis-ci.org/rdeits/iris-distro.svg)](https://travis-ci.org/rdeits/iris-distro)

Requirements
============

Ubuntu (with apt-get):

	pkg-config
	cmake
	libgmp-dev

Mac OSX (with homebrew):

	pkg-config
	cmake
	gmp

You'll also need some python packages to build and use the python bindings. You can install them on ubuntu with these apt-get packages:

    python-numpy
    python-scipy
    python-matplotlib
    python-nose
    cython

Or you can install the `liblapack-dev`, `libblas-dev`, and `gfortran` packages from apt-get, and then install the python modules with pip:

	pip install -r python_requirements.txt

You'll also need a license for the Mosek optimization toolbox <https://www.mosek.com/> (this package includes a downloader for the Mosek code, but you have to get your own license). Mosek has free licenses available for academic use.

Optionally, you can install the `cddmex` package for Matlab to speed up some functions (specifically, converting polytopes from an inequality representation to a set of vertices). The easiest way to get it is through [tbxmanager](http://tbxmanager.com/). If you're not planning on using the Matlab bindings, then you won't need it.

Installation
============

This project is distributed in accordance with the Pods guidelines: <http://sourceforge.net/p/pods/home/Home/>. If you've used pods before, then it should be easy to integrate IRIS along with your other Pods projects. If you haven't, then don't worry: Pods are designed to make it easy to build and run software like this without forcing you to install anything globally. You'll just have to do a few things:

First, you'll need to make a `build` folder where IRIS will be installed:

	mkdir build

Then build and install IRIS and its dependencies to that folder:

	make

To be able to use IRIS, you'll also need to update your `PATH`, `LD_LIBRARY_PATH`, `PYTHONPATH`, etc. The easiest way to do that is to add the following to your shell's startup file (for most Mac and Linux systems, that's `~/.bashrc`):

	source /wherever/you/put/iris-distro/build/config/pods_setup_all.sh

If you want to use the Matlab bindings, you'll also have to add the folder `wherever/you/put/iris-distro/build/matlab` to Matlab's path.

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

See `iris/src/iris_demo.cpp` for a basic usage example.

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
