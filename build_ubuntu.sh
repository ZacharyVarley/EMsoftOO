#!/bin/bash

# Install dependencies
sudo apt-get update
sudo apt-get install -y git vim wget cmake gcc gfortran ninja-build build-essential libopenblas-dev apt-utils opencl-headers ocl-icd-opencl-dev ocl-icd-libopencl1 libpocl-dev clinfo

# Set up OpenCL for Nvidia
sudo mkdir -p /etc/OpenCL/vendors
sudo echo "libnvidia-opencl.so.1" > /etc/OpenCL/vendors/nvidia.icd

# Clone EMsoft and set up SDK Debug/Release
mkdir -p /home/EMs
cd /home/EMs
git clone --branch developOO https://github.com/EMsoft-org/EMsoftSuperbuild.git
mv EMsoftSuperbuild EMsoftOOSuperbuild
cd EMsoftOOSuperbuild && mkdir Debug Release

# Build EMsoftSuperbuild
cd /home/EMs/EMsoftOOSuperbuild/Debug/
cmake -DEMsoftOO_SDK=/opt/EMsoftOO_SDK -DCMAKE_BUILD_TYPE=Debug ../ -G Ninja && ninja
cd ../Release
cmake -DEMsoftOO_SDK=/opt/EMsoftOO_SDK -DCMAKE_BUILD_TYPE=Release ../ -G Ninja && ninja

# Clone EMsoftOO and EMsoftData
cd /home/EMs
git clone https://github.com/EMsoft-org/EMsoftData.git
git clone https://github.com/EMsoft-org/EMsoftOO.git
mkdir EMsoftOOBuild

# Build EMsoftOO
cd /home/EMs/EMsoftOOBuild/ && mkdir Debug Release && cd Debug
cmake -DCMAKE_BUILD_TYPE=Debug -DEMsoftOO_SDK=/opt/EMsoftOO_SDK -DBUILD_SHARED_LIBS=OFF ../../EMsoftOO -G Ninja
ninja
cd ../Release
cmake -DCMAKE_BUILD_TYPE=Release -DEMsoftOO_SDK=/opt/EMsoftOO_SDK -DBUILD_SHARED_LIBS=OFF ../../EMsoftOO -G Ninja
ninja

# Package EMsoftOO
cd /home/EMs/EMsoftOOBuild/Release
cpack -G ZIP
