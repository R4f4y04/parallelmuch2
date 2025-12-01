# Architecture Diagram

## System Overview

```
┌─────────────────────────────────────────────────────────────┐
│                   USER INTERACTION                           │
│         (Dashboard → Select Algorithm → Configure)           │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                   FLUTTER FRONTEND                           │
│                  (Windows Desktop App)                       │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   Screens    │  │   Widgets    │  │   Services   │     │
│  │              │  │              │  │              │     │
│  │ - Dashboard  │  │ - AlgoCard   │  │ - Process    │     │
│  │ - Execution  │  │ - Charts     │  │   Runner     │     │
│  │ - History    │  │ - Terminal   │  │ - Parser     │     │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘     │
│         │                  │                  │              │
│         └──────────────────┼──────────────────┘              │
│                            │                                 │
│                    ┌───────▼────────┐                        │
│                    │  Data Models   │                        │
│                    │                │                        │
│                    │ - AlgoConfig   │                        │
│                    │ - BenchResult  │                        │
│                    │ - HardwareInfo │                        │
│                    └───────┬────────┘                        │
└────────────────────────────┼─────────────────────────────────┘
                             │
                             │ Process.run()
                             │ CLI Args: <size> <threads>
                             ▼
┌─────────────────────────────────────────────────────────────┐
│                     C BACKEND                                │
│                  (Native Executables)                        │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  backend/bin/                                        │   │
│  │                                                      │   │
│  │  matrix_mult.exe    [Cache Coherence]              │   │
│  │  merge_sort.exe     [Task Parallelism]             │   │
│  │  monte_carlo.exe    [Reduction]                     │   │
│  │  nbody.exe          [Dynamic Scheduling]            │   │
│  │  mandelbrot.exe     [Load Balance]                  │   │
│  └──────────────────────────────────────────────────────┘   │
│                            │                                 │
│                            │ OpenMP Parallelization          │
│                            ▼                                 │
│                  ┌─────────────────┐                         │
│                  │  omp_get_wtime() │                        │
│                  │  Timing & Exec   │                        │
│                  └─────────┬────────┘                        │
└──────────────────────────────┼──────────────────────────────┘
                               │
                               │ stdout (JSON)
                               │ {"algo": "...", "time": X}
                               ▼
┌─────────────────────────────────────────────────────────────┐
│               FLUTTER RECEIVES & PARSES                      │
│                                                              │
│  DataParsingService.parseResult()                            │
│  → BenchmarkResult object                                    │
│  → Calculate speedup & efficiency                            │
│  → Update UI charts                                          │
└─────────────────────────────────────────────────────────────┘
```

## Data Flow

### 1. User Selects Algorithm
```
Dashboard Screen
    │
    ├─ User clicks "Matrix Multiplication"
    │
    └─> Navigates to ExecutionScreen(algo: matrixConfig)
```

### 2. User Configures & Runs
```
ExecutionScreen
    │
    ├─ User sets: size=1024, threads=[1,2,4,8]
    │
    ├─ User clicks "EXECUTE BENCHMARK"
    │
    └─> ProcessRunnerService.runBenchmarkSuite()
```

### 3. Backend Execution Loop
```
For each thread count (1, 2, 4, 8):
    │
    ├─ Process.run("backend/bin/matrix_mult.exe 1024 <threads>")
    │
    ├─ C executable runs with OpenMP
    │   ├─ omp_set_num_threads(threads)
    │   ├─ double start = omp_get_wtime()
    │   ├─ // Parallel computation //
    │   ├─ double end = omp_get_wtime()
    │   └─ printf(JSON)
    │
    └─> Flutter receives: {"algo": "matrix_mult", "threads": 4, "time": 0.345}
```

### 4. Result Processing
```
DataParsingService
    │
    ├─ Parse JSON → BenchmarkResult object
    │
    ├─ Calculate metrics:
    │   ├─ speedup = baseline_time / parallel_time
    │   └─ efficiency = speedup / threads
    │
    └─> Update State → Trigger UI Rebuild
```

### 5. Visualization Update
```
SpeedupChart Widget
    │
    ├─ Receives List<BenchmarkResult>
    │
    ├─ Maps to fl_chart data points
    │   └─ FlSpot(threads, speedup)
    │
    └─> Renders line chart with:
        ├─ Observed speedup curve (teal)
        └─ Ideal linear speedup (amber dashed)
```

## Component Dependencies

### Frontend Dependencies
```
main.dart
    ├─> screens/dashboard_screen.dart
    │       └─> widgets/algo_card.dart
    │       └─> models/algo_config.dart
    │
    └─> screens/execution_screen.dart
            ├─> widgets/config_panel.dart
            ├─> widgets/speedup_chart.dart
            ├─> widgets/terminal_output_box.dart
            ├─> services/process_runner_service.dart
            └─> services/data_parsing_service.dart
```

### Backend Dependencies
```
src/*.c
    ├─> include/common_utils.h
    ├─> <omp.h>
    ├─> <stdio.h>
    └─> <stdlib.h>
```

## Communication Protocol

### Input (Flutter → C)
```
Command Line Arguments:
    Argument 1: Problem size (int)
    Argument 2: Thread count (int)

Example: ./matrix_mult.exe 1024 8
```

### Output (C → Flutter)
```json
{
    "algo": "string",      // Algorithm identifier
    "threads": int,        // Number of threads used
    "size": int,           // Problem size
    "time": float          // Execution time in seconds
}
```

### Error Handling
```
C stderr → Flutter onStderr callback
    │
    └─> DataParsingService.parseError()
            └─> User-friendly error message
                └─> SnackBar notification
```

## State Management Flow

```
ProviderScope (Riverpod)
    │
    └─> ConsumerWidget (ExecutionScreen)
            │
            ├─ Local State:
            │   ├─ List<BenchmarkResult> _results
            │   ├─ String _terminalOutput
            │   ├─ bool _isRunning
            │   └─ int _currentIteration
            │
            └─> setState() triggers rebuild
                    │
                    └─> Widgets rebuild with new data
                            ├─ SpeedupChart
                            ├─ TerminalOutputBox
                            └─ DataTable
```

## Thread Execution Model (Backend)

```
Main Thread
    │
    ├─ Parse args
    ├─ Allocate memory
    ├─ omp_set_num_threads(N)
    │
    └─> #pragma omp parallel
            │
            ├─ Thread 0 ────┐
            ├─ Thread 1 ────┤
            ├─ Thread 2 ────┼─> Parallel Region
            ├─ Thread 3 ────┤   (Work Distribution)
            └─ Thread N-1 ──┘
            │
            └─> Implicit Barrier
                    │
                    └─> Main Thread continues
                            └─> Print JSON
```

## File Structure Rationale

```
Why This Structure?

lib/models/          → Data contracts (no logic)
lib/services/        → Business logic (no UI)
lib/widgets/         → Reusable UI (no business logic)
lib/screens/         → Full pages (compose widgets)

backend/src/         → Algorithm implementations
backend/include/     → Shared utilities
backend/bin/         → Compiled outputs (gitignored)
```

## Performance Monitoring Flow

```
1. Serial Execution (baseline)
   ├─ Run with threads=1
   └─> Store as baseline_time

2. Parallel Executions
   ├─ Run with threads=2,4,8,...
   └─> For each:
       ├─ speedup = baseline_time / parallel_time
       └─ efficiency = speedup / threads

3. Visualization
   └─> Plot speedup vs threads
       ├─ Compare with ideal (y=x)
       └─> Identify scaling bottlenecks
```

---

This architecture ensures:
- ✅ Separation of concerns
- ✅ Type safety
- ✅ Easy testing
- ✅ Clear data flow
- ✅ Educational transparency
