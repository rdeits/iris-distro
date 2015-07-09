from distutils.core import setup, Extension
from Cython.Build import cythonize

import numpy

setup(ext_modules = cythonize(Extension(
    "iriscore",
    sources=["iriscore.pyx"],
    language="c++",
    include_dirs=[numpy.get_include(), "."],
    libraries=["iris_core", "iris_mosek", "mosek64", "iris_cvxgen_ldp_cpp"],
        )))
