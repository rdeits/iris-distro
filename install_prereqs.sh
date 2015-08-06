#!/bin/bash

case $1 in
  ("homebrew")
    brew install cmake pkg-config gmp openblas && easy_install pip && pip install virtualenv ;;
  ("ubuntu")
    apt-get install cmake build-essential libgmp-dev python-pip liblapack-dev libblas-dev gfortran python-virtualenv ;;
  (*)
    echo "Usage: ./install_prereqs.sh package_manager"
    echo "where package_manager is one of the following: "
    echo "  homebrew"
    echo "  ubuntu"
    exit 1 ;;
esac
