# -*- mode: python -*-
# vi: set ft=python :

workspace(name = "iris_distro")

load(
    "//tools/third_party/kythe/tools/build_rules/config:pkg_config.bzl",
    "pkg_config_package"
)

new_http_archive(
    name = "cdd",
    build_file = "tools/cdd.BUILD",
    sha256 = "fe6d04d494683cd451be5f6fe785e147f24e8ce3ef7387f048e739ceb4565ab5",
    strip_prefix = "cddlib-094h/lib-src",
    url = "https://s3.amazonaws.com/drake-provisioning/cddlib-094h.tar.gz",
)

new_http_archive(
    name = "eigen",
    build_file = "tools/eigen.BUILD",
    sha256 = "d64332c92e31803d2c59f6646ed893965c666acfc7c284e4f5e9ffbb4d148922",
    strip_prefix = "eigen-eigen-10219c95fe65",
    url = "https://bitbucket.org/eigen/eigen/get/3.2.4.tar.bz2",
)

# TODO: Download MOSEK using Bazel.

pkg_config_package(
    name = "mosek",
    modname = "mosek",
    atleast_version = "7.1",
)

new_http_archive(
    name = "pybind11",
    build_file = "tools/pybind11.BUILD",
    sha256 = "f13ece8f0a655f5691279123ea738cc55d3af8104c5cbaffd9b15875e54681f2",
    strip_prefix = "pybind11-7830e8509f2adc97ce9ee32bf99cd4b82089cc4c/include",
    url = "https://github.com/pybind/pybind11/archive/7830e8509f2adc97ce9ee32bf99cd4b82089cc4c.tar.gz",
)

# TODO: Add support for Python 3.x.

pkg_config_package(
    name = "python",
    modname = "python2",
    atleast_version = "2.7",
)

# TODO: Add Matplotlib, NumPy, and SciPy to the Bazel build.
