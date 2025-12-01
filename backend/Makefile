# Makefile for Parallel Architecture Workbench Backend
# Windows-compatible (MinGW-w64)
# 
# Requirements:
#   - GCC with OpenMP support (MinGW-w64 or MSYS2)
#   - Make utility
#
# Usage:
#   make all      - Compile all benchmarks
#   make clean    - Remove compiled binaries
#   make test     - Run quick tests

CC = gcc
CFLAGS = -O3 -fopenmp -Wall -Wextra -I./include
LDFLAGS = -fopenmp -lm

# Directories
SRC_DIR = src
BIN_DIR = bin
INCLUDE_DIR = include

# Source files
SOURCES = $(wildcard $(SRC_DIR)/*.c)
# Executables (with .exe extension for Windows)
EXECUTABLES = $(patsubst $(SRC_DIR)/%.c,$(BIN_DIR)/%.exe,$(SOURCES))

# Default target
all: $(BIN_DIR) $(EXECUTABLES)
	@echo.
	@echo ========================================
	@echo Build complete!
	@echo Executables in: $(BIN_DIR)
	@echo ========================================
	@echo.

# Create bin directory if it doesn't exist
$(BIN_DIR):
	@if not exist "$(BIN_DIR)" mkdir "$(BIN_DIR)"

# Compilation rule
$(BIN_DIR)/%.exe: $(SRC_DIR)/%.c $(INCLUDE_DIR)/common_utils.h
	@echo Compiling $<...
	$(CC) $(CFLAGS) $< -o $@ $(LDFLAGS)

# Clean target
clean:
	@if exist "$(BIN_DIR)\*.exe" del /Q "$(BIN_DIR)\*.exe"
	@if exist "$(BIN_DIR)" rmdir "$(BIN_DIR)"
	@echo Cleaned build artifacts

# Test target - run quick smoke tests
test: all
	@echo.
	@echo Running smoke tests...
	@echo.
	@echo [1/5] Matrix Multiplication (256x256, 2 threads)
	@$(BIN_DIR)\matrix_mult.exe 256 2
	@echo.
	@echo [2/5] Merge Sort (100000 elements, 2 threads)
	@$(BIN_DIR)\merge_sort.exe 100000 2
	@echo.
	@echo [3/5] Monte Carlo (1000000 samples, 2 threads)
	@$(BIN_DIR)\monte_carlo.exe 1000000 2
	@echo.
	@echo [4/5] N-Body (1000 bodies, 2 threads)
	@$(BIN_DIR)\nbody.exe 1000 2
	@echo.
	@echo [5/5] Mandelbrot (512x512, 2 threads)
	@$(BIN_DIR)\mandelbrot.exe 512 2
	@echo.
	@echo ========================================
	@echo All tests passed!
	@echo ========================================

# Help target
help:
	@echo Parallel Architecture Workbench - Backend Makefile
	@echo.
	@echo Targets:
	@echo   all     - Compile all benchmark executables (default)
	@echo   clean   - Remove compiled binaries
	@echo   test    - Run quick smoke tests
	@echo   help    - Show this help message
	@echo.
	@echo Requirements:
	@echo   - GCC with OpenMP support (MinGW-w64)
	@echo   - Make utility
	@echo.
	@echo Compiler flags:
	@echo   $(CFLAGS)

.PHONY: all clean test help
