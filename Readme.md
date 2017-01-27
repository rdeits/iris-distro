Introduction
============

This package contains the IRIS algorithm for iterative convex regional inflation by semidefinite programming, implemented in C++ with bindings for Python. It is designed to take an environment containing many (convex) obstacles and a start point, and to compute a large convex obstacle-free region. This region can then be used to define linear constraints for some other objective function which the user might want to optimize over the obstacle-free space. The algorithm is described in:

R.&nbsp;L.&nbsp;H. Deits and R.&nbsp;Tedrake, &ldquo;Computing large convex regions of
  obstacle-free space through semidefinite programming,&rdquo; <em>Workshop on the Algorithmic Fundamentals of Robotics</em>, Istanbul, Aug. 2014.
  [Online]. Available:
  <a href='http://groups.csail.mit.edu/robotics-center/public_papers/Deits14.pdf'>http://groups.csail.mit.edu/robotics-center/public_papers/Deits14.pdf</a>

[![Build Status](https://travis-ci.org/rdeits/iris-distro.svg)](https://travis-ci.org/rdeits/iris-distro)

MATLAB Support
==============

A pure-MATLAB implementation of IRIS is also included in `src/matlab`. This will be slower and less flexible than the Python and C++ versions, but may be useful for legacy code.

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

Installation
============

This project is configured as a standard CMake project, so the general build process is:

	mkdir build
	cd build
	cmake ..
	make

------------------------------
Installation without externals
------------------------------
By default, IRIS will build its external dependencies as part of the build process. If you want to turn any or all of them off, you can set the `WITH_EIGEN`, `WITH_CDD`, and `WITH_MOSEK` options to `OFF` using cmake. The easiest way to do that is to run:

    cd build
    ccmake .

which will launch a terminal-based GUI to let you change those options. 

If you're using IRIS as part of another project with cmake, you can just set the CMAKE_CACHE_ARGS to include `-DIRIS_WITH_EIGEN:BOOL=OFF` etc. For more information, see: <http://www.cmake.org/cmake/help/v3.0/module/ExternalProject.html>.

Example Usage
=============

Python wrapper
--------------

	python -m irispy.test.test_iris_2d

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
