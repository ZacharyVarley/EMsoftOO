@echo off
setlocal enabledelayedexpansion

:: Set root directory
set "ROOT_DIR=%CD%"

:: Install Chocolatey (if not already installed)
where choco >nul 2>nul
if %ERRORLEVEL% neq 0 (
    @"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
)

:: Install required tools
choco install -y cmake ninja visualstudio2019buildtools visualstudio2019-workload-vctools mingw

:: Set up Visual Studio environment
call "C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Auxiliary\Build\vcvars64.bat"

:: Set up environment variables
set "PATH=%PATH%;C:\Program Files\CMake\bin;C:\ProgramData\chocolatey\bin;C:\tools\mingw64\bin"
set "FC=gfortran"

:: Verify installations
where cmake
where ninja
where cl
where gfortran

:: Install vcpkg and required libraries
if not exist vcpkg (
    git clone https://github.com/Microsoft/vcpkg.git
    cd vcpkg
    call bootstrap-vcpkg.bat
) else (
    cd vcpkg
)
vcpkg integrate install
vcpkg install opencl:x64-windows
vcpkg install openblas:x64-windows

:: Set VCPKG_ROOT environment variable
set "VCPKG_ROOT=%CD%"
cd %ROOT_DIR%

:: Create EMsoftOO_SDK directory
if not exist C:\EMsoftOO_SDK mkdir C:\EMsoftOO_SDK

:: Clone EMsoft and set up SDK
if not exist EMsoftOOSuperbuild (
    git clone --branch developOO https://github.com/EMsoft-org/EMsoftSuperbuild.git EMsoftOOSuperbuild
)
cd EMsoftOOSuperbuild
if not exist Release mkdir Release
cd Release

:: Configure and build EMsoftSuperbuild
cmake -DEMsoftOO_SDK=C:\EMsoftOO_SDK -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=%VCPKG_ROOT%\scripts\buildsystems\vcpkg.cmake -DCMAKE_C_COMPILER=cl -DCMAKE_CXX_COMPILER=cl -DCMAKE_Fortran_COMPILER=gfortran -G "Ninja" ..
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%
ninja
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

:: Clone EMsoftOO and EMsoftData
cd %ROOT_DIR%
if not exist EMsoftData git clone https://github.com/EMsoft-org/EMsoftData.git
if not exist EMsoftOO git clone https://github.com/ZacharyVarley/EMsoftOO.git
if not exist EMsoftOOBuild mkdir EMsoftOOBuild

:: Build EMsoftOO
cd EMsoftOOBuild
if not exist Release mkdir Release
cd Release
cmake -DCMAKE_BUILD_TYPE=Release -DEMsoftOO_SDK=C:\EMsoftOO_SDK -DBUILD_SHARED_LIBS=OFF -DCMAKE_TOOLCHAIN_FILE=%VCPKG_ROOT%\scripts\buildsystems\vcpkg.cmake -DCMAKE_C_COMPILER=cl -DCMAKE_CXX_COMPILER=cl -DCMAKE_Fortran_COMPILER=gfortran -G "Ninja" %ROOT_DIR%\EMsoftOO
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%
ninja
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

:: Package EMsoftOO
cpack -G ZIP
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

echo Build completed successfully!
