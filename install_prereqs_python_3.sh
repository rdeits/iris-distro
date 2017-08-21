#!/bin/bash

set -euo pipefail

case "${1:-}" in
  ("homebrew")
    brew install cmake gmp numpy python3 scipy
    pip3 install matplotlib nose
    ;;
  ("macports")
    port install cmake gmp py36-matplotlib py36-nose py36-numpy py36-scipy \
      python36
    ;;
  ("ubuntu")
    apt-get install --no-install-recommends cmake g++ gcc git libgmp-dev make \
      python3 python3-matplotlib python3-nose python3-numpy python3-scipy
    ;;
  (*)
    echo "Usage: $0 <package_manager>" 1>&2
    echo "where <package_manager> is one of the following:" 1>&2
    echo "  homebrew" 1>&2
    echo "  macports" 1>&2
    echo "  ubuntu" 1>&2
    exit 1
    ;;
esac
