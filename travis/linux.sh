set -e

mkdir -p ~/tools
pushd ~/tools

wget https://cmake.org/files/v3.5/cmake-3.5.2-Linux-x86_64.tar.gz
tar zxvf cmake-3.5.2-Linux-x86_64.tar.gz
rm cmake-3.5.2-Linux-x86_64.tar.gz
cd cmake-3.5.2-Linux-x86_64/bin
export PATH=`pwd`:$PATH
popd

sudo apt-get install -y pkg-config libgmp-dev
