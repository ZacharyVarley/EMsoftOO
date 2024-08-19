#!/bin/bash

# Clone EMsoft and set up SDK Debug/Release
git clone --branch developOO https://github.com/EMsoft-org/EMsoftSuperbuild.git
mv EMsoftSuperbuild EMsoftOOSuperbuild
cd EMsoftOOSuperbuild && mkdir Release && cd Release

# Build EMsoftSuperbuild
cmake -DEMsoftOO_SDK=/opt/EMsoftOO_SDK -DCMAKE_BUILD_TYPE=Release ../ -G Ninja && ninja

# Clone EMsoftOO and EMsoftData
cd ../..
git clone https://github.com/EMsoft-org/EMsoftData.git
git clone https://github.com/ZacharyVarley/EMsoftOO.git
mkdir -p EMsoftOOBuild

# Build EMsoftOO
cd EMsoftOOBuild && mkdir Release && cd Release
cmake -DCMAKE_BUILD_TYPE=Release -DEMsoftOO_SDK=/opt/EMsoftOO_SDK -DBUILD_SHARED_LIBS=OFF ../../EMsoftOO -G Ninja && ninja

# Package Release EMsoftOO
cpack -G DragNDrop
