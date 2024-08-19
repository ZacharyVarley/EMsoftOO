#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status.
set -x  # Print commands and their arguments as they are executed.

# Update and install dependencies
brew upgrade
brew install gcc cmake ninja openblas open-mpi

# Find gfortran path
GFORTRAN_PATH=$(brew --prefix gcc)/bin/gfortran
echo "gfortran path: $GFORTRAN_PATH"

# Verify gfortran exists
if [ ! -f "$GFORTRAN_PATH" ]; then
    echo "Error: gfortran not found at $GFORTRAN_PATH"
    exit 1
fi

# Clone EMsoft and set up SDK Release
git clone --branch developOO https://github.com/EMsoft-org/EMsoftSuperbuild.git
mv EMsoftSuperbuild EMsoftOOSuperbuild
cd EMsoftOOSuperbuild && mkdir Release && cd Release

# Build EMsoftSuperbuild
cmake -DEMsoftOO_SDK=/opt/EMsoftOO_SDK -DCMAKE_BUILD_TYPE=Release -DCMAKE_Fortran_COMPILER=$GFORTRAN_PATH ../ -G Ninja && ninja

# Clone EMsoftOO and EMsoftData
cd ../..
git clone https://github.com/EMsoft-org/EMsoftData.git
git clone https://github.com/ZacharyVarley/EMsoftOO.git
mkdir -p EMsoftOOBuild

# Build EMsoftOO
cd EMsoftOOBuild && mkdir Release && cd Release
cmake -DCMAKE_BUILD_TYPE=Release -DEMsoftOO_SDK=/opt/EMsoftOO_SDK -DBUILD_SHARED_LIBS=OFF -DCMAKE_Fortran_COMPILER=$GFORTRAN_PATH ../../EMsoftOO -G Ninja && ninja

# Package Release EMsoftOO
cpack -G DragNDrop
