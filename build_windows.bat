@echo off
setlocal enabledelayedexpansion

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

:: Create EMsoftOO_SDK directory
mkdir C:\EMsoftOO_SDK

:: Clone EMsoft and set up SDK
git clone --branch developOO https://github.com/EMsoft-org/EMsoftSuperbuild.git
rename EMsoftSuperbuild EMsoftOOSuperbuild
cd EMsoftOOSuperbuild
mkdir Release && cd Release

:: Configure and build EMsoftSuperbuild
cmake -DEMsoftOO_SDK=C:\EMsoftOO_SDK -DCMAKE_BUILD_TYPE=Release -G "Ninja" ..
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%
ninja
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

:: Clone EMsoftOO and EMsoftData
cd ..\..
git clone https://github.com/EMsoft-org/EMsoftData.git
git clone https://github.com/ZacharyVarley/EMsoftOO.git
mkdir EMsoftOOBuild

:: Build EMsoftOO
cd EMsoftOOBuild
mkdir Release && cd Release
cmake -DCMAKE_BUILD_TYPE=Release -DEMsoftOO_SDK=C:\EMsoftOO_SDK -DBUILD_SHARED_LIBS=OFF -G "Ninja" ../../EMsoftOO
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%
ninja
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

:: Package EMsoftOO
cpack -G ZIP
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

echo Build completed successfully!
