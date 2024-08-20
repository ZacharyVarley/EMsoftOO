@echo off
setlocal enabledelayedexpansion

:: Set up environment variables
set "PATH=%PATH%;C:\Program Files\CMake\bin"

:: Clone EMsoft and set up SDK
git clone --branch developOO https://github.com/EMsoft-org/EMsoftSuperbuild.git
rename EMsoftSuperbuild EMsoftOOSuperbuild
cd EMsoftOOSuperbuild
mkdir Release && cd Release

:: Configure and build EMsoftSuperbuild
cmake -DEMsoftOO_SDK=C:\EMsoftOO_SDK -DCMAKE_BUILD_TYPE=Release ../ -G "Ninja"
ninja

:: Clone EMsoftOO and EMsoftData
cd ..\..
git clone https://github.com/EMsoft-org/EMsoftData.git
git clone https://github.com/ZacharyVarley/EMsoftOO.git
mkdir EMsoftOOBuild

:: Build EMsoftOO
cd EMsoftOOBuild
mkdir Release && cd Release
cmake -DCMAKE_BUILD_TYPE=Release -DEMsoftOO_SDK=C:\EMsoftOO_SDK -DBUILD_SHARED_LIBS=OFF ../../EMsoftOO -G "Ninja"
ninja

:: Package EMsoftOO
cpack -G ZIP

echo Build completed successfully!
