#!/bin/bash

case $1 in
  ("homebrew")
    brew install cmake pkg-config gmp openblas swig && easy_install pip && pip install -r python_requirements.txt ;;
  ("macports")
    port install cmake gmp openblas swig python27 py-pip py-scipy py-numpy py-matplotlib py-nose ;;
  ("ubuntu")
    apt-get install cmake build-essential libgmp-dev python-pip liblapack-dev libblas-dev gfortran python-scipy python-numpy python-matplotlib python-nose swig ;;
  (*)
    echo "Usage: ./install_prereqs.sh package_manager"
    echo "where package_manager is one of the following: "
    echo "  homebrew"
    echo "  ubuntu"
    exit 1 ;;
esac
