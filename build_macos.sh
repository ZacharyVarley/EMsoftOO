#!/bin/bash

# Find gfortran path
GFORTRAN_PATH=$(brew --prefix gcc)/bin/gfortran
echo "gfortran path: $GFORTRAN_PATH"

# Clone EMsoft and set up SDK Release
git clone --branch developOO https://github.com/EMsoft-org/EMsoftSuperbuild.git
mv EMsoftSuperbuild EMsoftOOSuperbuild
cd EMsoftOOSuperbuild && mkdir Release && cd Release

# Build EMsoftSuperbuild
sudo cmake -DEMsoftOO_SDK=/opt/EMsoftOO_SDK -DCMAKE_BUILD_TYPE=Release -DCMAKE_Fortran_COMPILER=$GFORTRAN_PATH ../ -G Ninja && sudo ninja

# Clone EMsoftOO and EMsoftData
cd ../..
git clone https://github.com/EMsoft-org/EMsoftData.git
git clone https://github.com/ZacharyVarley/EMsoftOO.git
sudo mkdir -p EMsoftOOBuild

# Build EMsoftOO
cd EMsoftOOBuild && mkdir Release && cd Release
sudo cmake -DCMAKE_BUILD_TYPE=Release -DEMsoftOO_SDK=/opt/EMsoftOO_SDK -DBUILD_SHARED_LIBS=OFF -DCMAKE_Fortran_COMPILER=$GFORTRAN_PATH ../../EMsoftOO -G Ninja && sudo ninja

# Package Release EMsoftOO
cpack -G DragNDrop
