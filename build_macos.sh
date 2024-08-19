#!/bin/bash

# Find gfortran path
export FC=$(brew --prefix gcc)/bin/gfortran
export FC_PATH=$(brew --prefix gcc)/bin/gfortran
echo FC
echo FC_PATH

# Clone EMsoft and set up SDK Release
git clone --branch developOO https://github.com/EMsoft-org/EMsoftSuperbuild.git
sudo mv EMsoftSuperbuild EMsoftOOSuperbuild
cd EMsoftOOSuperbuild && sudo mkdir Release && cd Release

# Build EMsoftSuperbuild
sudo cmake -DEMsoftOO_SDK=/opt/EMsoftOO_SDK -DCMAKE_BUILD_TYPE=Release -DCMAKE_Fortran_COMPILER=$FC_PATH ../ -G Ninja && sudo ninja

# Display configuration logs for debugging
echo "nlopt configuration log:"
cat /opt/EMsoftOO_SDK/superbuild/nlopt-2.7.0/Stamp/nlopt-configure-*.log

echo "CLFortran configuration log:"
cat /opt/EMsoftOO_SDK/superbuild/CLFortran/Stamp/Release/CLFortran-configure-*.log

# Clone EMsoftOO and EMsoftData
cd ../..
git clone https://github.com/EMsoft-org/EMsoftData.git
git clone https://github.com/ZacharyVarley/EMsoftOO.git
sudo mkdir EMsoftOOBuild

# Build EMsoftOO
cd EMsoftOOBuild && sudo mkdir Release && cd Release
sudo cmake -DCMAKE_BUILD_TYPE=Release -DEMsoftOO_SDK=/opt/EMsoftOO_SDK -DBUILD_SHARED_LIBS=OFF -DCMAKE_Fortran_COMPILER=$FC_PATH ../../EMsoftOO -G Ninja && sudo ninja

# Package Release EMsoftOO
cpack -G DragNDrop
