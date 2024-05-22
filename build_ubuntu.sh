#!/bin/bash
# Clone EMsoft and set up SDK
cd $HOME
git clone --branch developOO https://github.com/EMsoft-org/EMsoftSuperbuild.git
mv EMsoftSuperbuild EMsoftOOSuperbuild
cd EMsoftOOSuperbuild && mkdir Release

# Build EMsoftSuperbuild
cd $HOME/EMsoftOOSuperbuild/Release/
cmake -DEMsoftOO_SDK=$HOME/EMsoftOO_SDK -DCMAKE_BUILD_TYPE=Release ../ -G Ninja && ninja

# Clone EMsoftOO and EMsoftData
cd $HOME
git clone https://github.com/EMsoft-org/EMsoftData.git
git clone https://github.com/EMsoft-org/EMsoftOO.git
mkdir EMsoftOOBuild

# Build EMsoftOO
cd $HOME/EMsoftOOBuild/ && mkdir Release && cd Release
cmake -DCMAKE_BUILD_TYPE=Release -DEMsoftOO_SDK=$HOME/EMsoftOO_SDK -DBUILD_SHARED_LIBS=OFF ../../EMsoftOO -G Ninja
ninja

# Package EMsoftOO
cpack -G ZIP
