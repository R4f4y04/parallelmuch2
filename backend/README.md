# Parallel Architecture Workbench - Backend

This directory contains the C/OpenMP implementations of parallel algorithms.

## Prerequisites

### Windows (Recommended: MSYS2 + MinGW-w64)

1. **Install MSYS2**: Download from https://www.msys2.org/
2. **Install GCC with OpenMP**:
   ```bash
   pacman -S mingw-w64-x86_64-gcc
   pacman -S make
   ```
3. **Add to PATH**: Add `C:\msys64\mingw64\bin` to your system PATH

### Alternative: MinGW-w64 Standalone
Download from: https://sourceforge.net/projects/mingw-w64/

## Build Instructions

### Compile All Benchmarks
```bash
cd backend
make all
```

This will compile all `.c` files in `src/` and place executables in `bin/`.

### Run Tests
```bash
make test
```

Runs quick smoke tests to verify all executables work.

### Clean Build Artifacts
```bash
make clean
```

## Algorithm Implementations

| File | Algorithm | Complexity | Key Concept |
|------|-----------|------------|-------------|
| `matrix_mult.c` | Matrix Multiplication | O(N³) | Cache Coherence, False Sharing |
| `merge_sort.c` | Merge Sort | O(N log N) | Recursive Parallelism, Tasks |
| `monte_carlo.c` | Pi Estimation | O(N) | Embarrassingly Parallel |
| `nbody.c` | N-Body Simulation | O(N²) | Fine-grained Parallelism |
| `mandelbrot.c` | Fractal Generation | O(N² × k) | Load Imbalance, Dynamic Scheduling |

## Usage

Each executable takes two arguments:
```bash
./bin/algorithm.exe <problem_size> <num_threads>
```

Example:
```bash
./bin/matrix_mult.exe 1024 8
```

Output (JSON format):
```json
{"algo": "matrix_mult", "threads": 8, "size": 1024, "time": 0.452000}
```

## Compiler Flags

- `-O3`: Maximum optimization
- `-fopenmp`: Enable OpenMP support
- `-Wall -Wextra`: Enable all warnings
- `-lm`: Link math library

## Troubleshooting

### "command not found: gcc"
- Ensure GCC is installed and in PATH
- Verify: `gcc --version`

### "undefined reference to `omp_get_wtime`"
- OpenMP not linked correctly
- Ensure `-fopenmp` flag is present

### Segmentation Fault
- Problem size may be too large for available memory
- Reduce size or increase system RAM

## Integration with Flutter

The Flutter app (`ProcessRunnerService`) executes these binaries and parses the JSON output. Ensure:
1. Executables are compiled before running the Flutter app
2. Path to `bin/` directory is correct in Flutter configuration
