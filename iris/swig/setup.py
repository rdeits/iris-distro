from distutils.core import setup, Extension
import numpy
numpyinclude = numpy.get_include()
irispy_swig = Extension("_irispy_swig",
                     sources=["irispy_swig_wrap.cxx"],
                     include_dirs=[numpyinclude, "/home/rdeits/locomotion/iris-distro/build/include/eigen3", "../src"])
setup(name = "irispy_swig",
      version = "0.0",
      author = "Robin Deits",
      description = "",
      ext_modules = [irispy_swig],
      py_modules = ["irispy_swig"])