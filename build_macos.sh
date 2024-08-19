#!/bin/bash

# Install dependencies using Homebrew
brew install git vim wget cmake gcc gfortran ninja openblas

# Clone EMsoft and set up SDK Debug/Release
mkdir -p /Users/EMs
cd /Users/EMs
git clone --branch developOO https://github.com/EMsoft-org/EMsoftSuperbuild.git
mv EMsoftSuperbuild EMsoftOOSuperbuild
cd EMsoftOOSuperbuild && mkdir Debug Release

# Build EMsoftSuperbuild
cd /Users/EMs/EMsoftOOSuperbuild/Debug/
cmake -DEMsoftOO_SDK=/opt/EMsoftOO_SDK -DCMAKE_BUILD_TYPE=Debug ../ -G Ninja && ninja
cd ../Release
cmake -DEMsoftOO_SDK=/opt/EMsoftOO_SDK -DCMAKE_BUILD_TYPE=Release ../ -G Ninja && ninja

# Clone EMsoftOO and EMsoftData
cd /Users/EMs
git clone https://github.com/EMsoft-org/EMsoftData.git
git clone https://github.com/ZacharyVarley/EMsoftOO.git
mkdir EMsoftOOBuild

# Build EMsoftOO
cd /Users/EMs/EMsoftOOBuild/ && mkdir Debug Release && cd Debug
cmake -DCMAKE_BUILD_TYPE=Debug -DEMsoftOO_SDK=/opt/EMsoftOO_SDK -DBUILD_SHARED_LIBS=OFF ../../EMsoftOO -G Ninja
ninja
cd ../Release
cmake -DCMAKE_BUILD_TYPE=Release -DEMsoftOO_SDK=/opt/EMsoftOO_SDK -DBUILD_SHARED_LIBS=OFF ../../EMsoftOO -G Ninja
ninja

# Package EMsoftOO
cd /Users/EMs/EMsoftOOBuild/Release
cpack -G DragNDrop
