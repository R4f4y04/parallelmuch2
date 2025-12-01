@echo off
REM Batch script to compile C backend on Windows without make
REM Requires: GCC with OpenMP support (MinGW-w64 or MSYS2)

echo.
echo ========================================
echo Parallel Architecture Workbench
echo Backend Compilation Script
echo ========================================
echo.

REM Check if GCC is available
where gcc >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] GCC not found!
    echo.
    echo Please install MinGW-w64 or MSYS2:
    echo 1. Download MSYS2 from: https://www.msys2.org/
    echo 2. Install and run: pacman -S mingw-w64-x86_64-gcc
    echo 3. Add to PATH: C:\msys64\mingw64\bin
    echo.
    pause
    exit /b 1
)

echo [INFO] GCC found: 
gcc --version | findstr "gcc"
echo.

REM Create bin directory if it doesn't exist
if not exist "bin" mkdir bin

REM Compiler flags
set CFLAGS=-O3 -fopenmp -Wall -Wextra -I./include
set LDFLAGS=-fopenmp -lm

echo Compiling algorithms...
echo.

REM Compile each algorithm
echo [1/5] Matrix Multiplication...
gcc %CFLAGS% src/matrix_mult.c -o bin/matrix_mult.exe %LDFLAGS%
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to compile matrix_mult.c
    pause
    exit /b 1
)

echo [2/5] Merge Sort...
gcc %CFLAGS% src/merge_sort.c -o bin/merge_sort.exe %LDFLAGS%
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to compile merge_sort.c
    pause
    exit /b 1
)

echo [3/5] Monte Carlo...
gcc %CFLAGS% src/monte_carlo.c -o bin/monte_carlo.exe %LDFLAGS%
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to compile monte_carlo.c
    pause
    exit /b 1
)

echo [4/5] N-Body Simulation...
gcc %CFLAGS% src/nbody.c -o bin/nbody.exe %LDFLAGS%
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to compile nbody.c
    pause
    exit /b 1
)

echo [5/5] Mandelbrot Set...
gcc %CFLAGS% src/mandelbrot.c -o bin/mandelbrot.exe %LDFLAGS%
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to compile mandelbrot.c
    pause
    exit /b 1
)

echo.
echo ========================================
echo Build complete!
echo Executables in: bin\
echo ========================================
echo.

REM List compiled files
dir /B bin\*.exe

echo.
echo Run 'compile.bat test' to test executables
echo.

REM Run tests if requested
if "%1"=="test" (
    echo.
    echo Running smoke tests...
    echo.
    
    echo [Test 1/5] Matrix Multiplication
    bin\matrix_mult.exe 256 2
    echo.
    
    echo [Test 2/5] Merge Sort
    bin\merge_sort.exe 100000 2
    echo.
    
    echo [Test 3/5] Monte Carlo
    bin\monte_carlo.exe 1000000 2
    echo.
    
    echo [Test 4/5] N-Body
    bin\nbody.exe 1000 2
    echo.
    
    echo [Test 5/5] Mandelbrot
    bin\mandelbrot.exe 512 2
    echo.
    
    echo ========================================
    echo All tests passed!
    echo ========================================
)

pause
