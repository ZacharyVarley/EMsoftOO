@echo off
setlocal enabledelayedexpansion

:: Set root directory
set "ROOT_DIR=%CD%"

:: Install Chocolatey (if not already installed)
where choco >nul 2>nul
if %ERRORLEVEL% neq 0 (
    @"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
)

:: Install required tools and compilers
choco install -y cmake ninja mingw gfortran visualstudio2019buildtools visualstudio2019-workload-vctools

:: Set up environment variables
set "PATH=%PATH%;C:\Program Files\CMake\bin;C:\ProgramData\chocolatey\bin;C:\tools\mingw64\bin"
set "CC=gcc"
set "CXX=g++"
set "FC=gfortran"

:: Verify installations
where cmake
where ninja
where gcc
where g++
where gfortran

:: Install vcpkg and required libraries
git clone https://github.com/Microsoft/vcpkg.git
cd vcpkg
call bootstrap-vcpkg.bat
vcpkg integrate install
vcpkg install opencl:x64-windows
vcpkg install openblas:x64-windows

:: Set VCPKG_ROOT environment variable
set "VCPKG_ROOT=%CD%"
cd %ROOT_DIR%

:: Create EMsoftOO_SDK directory
mkdir C:\EMsoftOO_SDK

:: Clone EMsoft and set up SDK
git clone --branch developOO https://github.com/EMsoft-org/EMsoftSuperbuild.git
rename EMsoftSuperbuild EMsoftOOSuperbuild
cd EMsoftOOSuperbuild
mkdir Release && cd Release

:: Configure and build EMsoftSuperbuild
cmake -DEMsoftOO_SDK=C:\EMsoftOO_SDK -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=%VCPKG_ROOT%\scripts\buildsystems\vcpkg.cmake -G "Ninja" ..
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%
ninja
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

:: Clone EMsoftOO and EMsoftData
cd %ROOT_DIR%
git clone https://github.com/EMsoft-org/EMsoftData.git
git clone https://github.com/ZacharyVarley/EMsoftOO.git
mkdir EMsoftOOBuild

:: Build EMsoftOO
cd EMsoftOOBuild
mkdir Release && cd Release
cmake -DCMAKE_BUILD_TYPE=Release -DEMsoftOO_SDK=C:\EMsoftOO_SDK -DBUILD_SHARED_LIBS=OFF -DCMAKE_TOOLCHAIN_FILE=%VCPKG_ROOT%\scripts\buildsystems\vcpkg.cmake -G "Ninja" %ROOT_DIR%\EMsoftOO
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%
ninja
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

:: Package EMsoftOO
cpack -G ZIP
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

echo Build completed successfully!
