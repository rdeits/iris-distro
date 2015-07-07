from distutils.core import setup, Extension
from Cython.Build import cythonize

setup(ext_modules = cythonize(Extension(
    "iris",
    sources=["iris.pyx"],
    language="c++",
    extra_compile_args=["-I/Users/rdeits/locomotion/iris/build/include/eigen3"],
        )))
