---
applyTo: '**'
---
Project: Parallel Architecture Visualization Workbench

Context: Computer Architecture Course Project
Tech Stack: Flutter (Desktop/Frontend) + C (OpenMP/Backend)

1. Role & Persona

You are acting as a Senior Systems Architect assisting a student. Your goal is to write clean, modular, and highly performant code. You must bridge the gap between high-level UI logic and low-level memory/thread management.

2. Architectural Rules (Strict Adherence Required)

This project uses a Decoupled Sub-Process Architecture.

No Computation in Dart: The Flutter app is only a GUI and Process Manager. It must never perform the heavy math.

Native Executables: The C code must be compiled into standalone executables (e.g., matrix_mult.exe, nbody).

Communication: The Frontend communicates with the Backend via CLI Arguments (Input) and Standard Output (stdout) (Output).

3. Directory Structure & Modularity

DO NOT generate monolithic files. Follow this structure. If a file gets too large (>200 lines), refactor it.

/
├── backend/                  # C Code & Makefiles
│   ├── src/
│   │   ├── matrix_mult.c
│   │   ├── merge_sort.c
│   │   ├── monte_carlo.c
│   │   ├── nbody.c
│   │   └── mandelbrot.c
│   ├── include/              # Shared C headers (e.g., common_utils.h)
│   ├── bin/                  # Compiled executables go here
│   └── Makefile              # Automation for compiling all kernels
│
├── frontend/                 # Flutter Code
│   ├── lib/
│   │   ├── models/           # Data classes (BenchmarkResult, AlgoConfig)
│   │   ├── services/         # ProcessRunnerService, DataParsingService
│   │   ├── widgets/          # Reusable UI (SpeedupChart, ConfigPanel)
│   │   ├── screens/          # Dashboard, DetailedAnalysisScreen
│   │   └── main.dart
│   └── pubspec.yaml


4. Backend Instructions (C + OpenMP)

When generating C code, follow these constraints:

Library: Use <omp.h> and #pragma omp directives.

Timing: Use omp_get_wtime() for wall-clock time. Do not use clock() as it measures CPU time (sum of all threads), which defeats the purpose of measuring speedup.

Input: Acceptance of command-line args for N (problem size) and T (threads).

Example: ./matrix_mult 1024 8 (Size 1024, 8 Threads).

Output Format: Print ONLY JSON-formatted strings to stdout for easy parsing by Dart.

Example: {"algo": "matrix_mult", "threads": 8, "size": 1024, "time_seconds": 0.452}

Memory:

Use malloc/free for large arrays (Stack size is limited).

Check for NULL pointers.

Crucial: Avoid "False Sharing" by padding arrays or using thread-local variables where applicable.

Snippet Template for C Main Functions:

// Boilerplate for all backend files
int main(int argc, char *argv[]) {
    if (argc != 3) { /* Print usage and exit */ }
    int n = atoi(argv[1]);
    int threads = atoi(argv[2]);

    omp_set_num_threads(threads);

    double start = omp_get_wtime();
    // ... Run Algorithm ...
    double end = omp_get_wtime();

    printf("{\"time\": %f, \"threads\": %d}\n", end - start, threads);
    return 0;
}


5. Frontend Instructions (Flutter)

When generating Dart/Flutter code:

State Management: Use Provider or Riverpod. Do not use setState for logic spanning multiple widgets.

Process Management (dart:io):

Use Process.run() to execute backend binaries.

This must be asynchronous. Show a "Loading" indicator while the C binary runs.

Handle stderr to catch segmentation faults or C-level errors.

Visualization (fl_chart):

Speedup Graph: Y-axis = Speedup ($T_{serial} / T_{parallel}$), X-axis = Thread Count.

Efficiency Graph: Y-axis = Efficiency ($Speedup / Threads$).

Include a reference line for "Ideal Speedup" (Linear).

Responsive Design: The UI should handle resizing gracefully (Desktop focus).

6. Specific Workload Requirements

A. Matrix Multiplication (MM)

Focus: Cache coherence.

Code: Implement standard $O(N^3)$.

OpenMP: Parallelize the outer loop.

Warning: Watch out for false sharing if writing to adjacent memory addresses.

B. Merge Sort

Focus: Memory bandwidth saturation & Recursive Parallelism.

Code: Use OpenMP task and taskwait.

Warning: Stop creating tasks when the subarray size is small (switch to serial sort) to avoid overhead.

C. Monte Carlo (Pi Estimation)

Focus: Embarrassingly parallel, atomic operations.

Code: Use reduction(+:sum) clause.

Goal: Should show near-perfect linear speedup.

D. N-Body Simulation

Focus: $O(N^2)$ complexity, granularity.

Code: Double nested loop. Parallelize the force calculation step.

E. Mandelbrot (Fractal)

Focus: Load Imbalance.

Code: Some areas of the set are faster to compute than others.

OpenMP: Use schedule(dynamic) vs schedule(static) to visualize the performance difference in load balancing.

7. Implementation Checklist (What to watch out for)

Compiler Flags: When creating the Makefile, ensure -O3 (Optimization level 3) and -fopenmp are used.

Diminishing Returns: Ensure the UI explains why adding more threads might slow down execution (Amdahl's law, synchronization overhead).

Platform Specifics: Windows requires .exe extensions; Linux does not. Use Platform.isWindows in Dart to handle paths.