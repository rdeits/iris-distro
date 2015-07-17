from distutils.core import setup, Extension
from Cython.Build import cythonize

import numpy
import sys

setup(ext_modules = cythonize(Extension(
    "iriscore",
    sources=["iriscore.pyx", "../../src/iris.cpp"],
    language="c++",
    include_dirs=[numpy.get_include(), "."],
    libraries=["iris", "mosek64", "iris_cvxgen_ldp_cpp", "cdd"],
    extra_compile_args=["-std=c++11"] + (["-stdlib=libc++"] if "darwin" in sys.platform else []),
    extra_link_args=["-std=c++11"],
        )))
