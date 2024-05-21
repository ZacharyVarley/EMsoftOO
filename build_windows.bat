@echo off

rem Install dependencies using Chocolatey
choco install -y git vim wget cmake mingw-w64 openblas ninja

rem Clone EMsoft and set up SDK Debug/Release
mkdir C:\EMs
cd C:\EMs
git clone --branch developOO https://github.com/EMsoft-org/EMsoftSuperbuild.git
rename EMsoftSuperbuild EMsoftOOSuperbuild
cd EMsoftOOSuperbuild && mkdir Debug Release

rem Build EMsoftSuperbuild
cd C:\EMs\EMsoftOOSuperbuild\Debug
cmake -DEMsoftOO_SDK=C:\EMsoftOO_SDK -DCMAKE_BUILD_TYPE=Debug ../ -G Ninja && ninja
cd ..\Release
cmake -DEMsoftOO_SDK=C:\EMsoftOO_SDK -DCMAKE_BUILD_TYPE=Release ../ -G Ninja && ninja

rem Clone EMsoftOO and EMsoftData
cd C:\EMs
git clone https://github.com/EMsoft-org/EMsoftData.git
git clone https://github.com/EMsoft-org/EMsoftOO.git
mkdir EMsoftOOBuild

rem Build EMsoftOO
cd C:\EMs\EMsoftOOBuild && mkdir Debug Release && cd Debug
cmake -DCMAKE_BUILD_TYPE=Debug -DEMsoftOO_SDK=C:\EMsoftOO_SDK -DBUILD_SHARED_LIBS=OFF ..\..\EMsoftOO -G Ninja
ninja
cd ..\Release
cmake -DCMAKE_BUILD_TYPE=Release -DEMsoftOO_SDK=C:\EMsoftOO_SDK -DBUILD_SHARED_LIBS=OFF ..\..\EMsoftOO -G Ninja
ninja

rem Package EMsoftOO
cd C:\EMs\EMsoftOOBuild\Release
cpack -G ZIP
