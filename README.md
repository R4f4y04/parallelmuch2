# Parallel Architecture Visualization Workbench

A Computer Architecture Course Project demonstrating parallel performance characteristics using Flutter (Frontend) and C/OpenMP (Backend).

## 🎯 Project Overview

This desktop application visualizes the performance of parallel algorithms, helping students understand:
- **Speedup & Efficiency**: How performance scales with thread count
- **Amdahl's Law**: Theoretical vs actual speedup limits
- **Architectural Concepts**: Cache coherence, load balancing, memory bandwidth
- **OpenMP Patterns**: Task parallelism, reductions, dynamic scheduling

## 🏗️ Architecture

```
Decoupled Sub-Process Architecture
┌─────────────────────────┐
│   Flutter Frontend      │  ← GUI & Process Manager
│   (Dart/Desktop)        │    
└───────────┬─────────────┘
            │ CLI Args (Input)
            │ stdout (JSON Output)
            ▼
┌─────────────────────────┐
│   C Backend             │  ← Computation Engine
│   (OpenMP/Native)       │    
└─────────────────────────┘
```

**Key Principle**: Flutter never performs heavy computation—it only visualizes results from native executables.

## 📁 Project Structure

```
parallelmuch2/
├── lib/                          # Flutter Frontend
│   ├── models/                   # Data classes
│   │   ├── algo_config.dart      # Algorithm metadata
│   │   ├── benchmark_result.dart # Execution results
│   │   └── hardware_info.dart    # System hardware detection
│   ├── services/                 # Business logic
│   │   ├── process_runner_service.dart
│   │   └── data_parsing_service.dart
│   ├── widgets/                  # Reusable UI components
│   │   ├── algo_card.dart        # Algorithm card with tags
│   │   ├── hardware_info_badge.dart
│   │   ├── terminal_output_box.dart
│   │   ├── speedup_chart.dart    # fl_chart visualization
│   │   └── config_panel.dart     # Benchmark configuration
│   ├── screens/                  # Full-screen views
│   │   ├── dashboard_screen.dart # Workload grid
│   │   └── execution_screen.dart # Detailed analysis
│   └── main.dart                 # App entry point
│
├── backend/                      # C/OpenMP Backend
│   ├── src/                      # Algorithm implementations
│   │   ├── matrix_mult.c         # O(N³) - Cache coherence
│   │   ├── merge_sort.c          # O(N log N) - Task parallelism
│   │   ├── monte_carlo.c         # O(N) - Embarrassingly parallel
│   │   ├── nbody.c               # O(N²) - Fine-grained parallelism
│   │   └── mandelbrot.c          # O(N²×k) - Load imbalance
│   ├── include/
│   │   └── common_utils.h        # Shared utilities
│   ├── bin/                      # Compiled executables (.exe)
│   └── Makefile                  # Build automation
│
└── README.md                     # This file
```

## 🚀 Getting Started

### Prerequisites

1. **Flutter SDK** (3.8.1+)
   - Download: https://flutter.dev/docs/get-started/install
   - Verify: `flutter doctor`

2. **GCC with OpenMP** (MinGW-w64 or MSYS2)
   - Recommended: MSYS2 (https://www.msys2.org/)
   - Install GCC: `pacman -S mingw-w64-x86_64-gcc make`
   - Add to PATH: `C:\msys64\mingw64\bin`

### Setup Steps

#### 1. Clone/Download Project
```bash
cd parallelmuch2
```

#### 2. Install Flutter Dependencies
```powershell
flutter pub get
```

#### 3. Compile Backend (C Code)
```powershell
cd backend
make all
cd ..
```

Verify executables exist in `backend/bin/`:
- `matrix_mult.exe`
- `merge_sort.exe`
- `monte_carlo.exe`
- `nbody.exe`
- `mandelbrot.exe`

#### 4. Run the Application
```powershell
flutter run -d windows
```

## 🎮 Usage

### Dashboard Screen
- View all 5 available algorithms in a card grid
- Each card shows:
  - Algorithm name & description
  - Complexity notation (e.g., O(N³))
  - Architectural concepts (tags)
- **Quick Run**: Execute with default settings
- **Configure**: Open detailed execution screen

### Execution Screen
**Left Panel** (Configuration):
- Adjust problem size (N)
- Set thread range (min/max)
- Click "EXECUTE BENCHMARK"

**Right Panel** (Visualization):
- **Speedup Tab**: Plot of speedup vs thread count (with ideal linear reference)
- **Efficiency Tab**: Efficiency = Speedup / Threads
- **Raw Data Tab**: Table with exact timings

**Bottom Console**: Real-time JSON output from C backend

### Theory Corner
Educational sidebar with OpenMP tips:
- False sharing explanation
- Amdahl's Law formula
- Dynamic vs static scheduling
- Atomic operations
- NUMA awareness

## 📊 Algorithm Details

| Algorithm | Complexity | Parallelization Strategy | Expected Speedup |
|-----------|-----------|--------------------------|------------------|
| **Matrix Multiplication** | O(N³) | Parallelize outer loop (rows) | ~Linear (watch for false sharing) |
| **Merge Sort** | O(N log N) | Task-based recursive parallelism | ~Linear (with task threshold) |
| **Monte Carlo** | O(N) | Independent random sampling | **Near-perfect linear** |
| **N-Body Simulation** | O(N²) | Parallelize force calculations | ~Linear (fine-grained) |
| **Mandelbrot Set** | O(N²×k) | Dynamic scheduling for load balance | Variable (depends on region) |

## 🧪 Testing Backend

Run quick smoke tests:
```powershell
cd backend
make test
```

Manual test example:
```powershell
.\backend\bin\matrix_mult.exe 512 4
```

Expected output:
```json
{"algo": "matrix_mult", "threads": 4, "size": 512, "time": 0.123456}
```

## 🎨 UI/UX Features

### Design System
- **Theme**: Modern Technical Dark Mode
- **Colors**:
  - Primary: Deep Teal (`#00D4AA`) - Logic/Computation
  - Tertiary: Neon Amber (`#FFB020`) - Warnings/Overhead
  - Background: GitHub Dark (`#0D1117`)
- **Typography**:
  - Headers: JetBrains Mono (Monospace)
  - Body: Inter (Sans-serif)

### Key Components
1. **HardwareInfoBadge**: Shows detected CPU cores/architecture
2. **AlgoCard**: Card with complexity tags and icons
3. **SpeedupChart**: Interactive fl_chart visualization
4. **TerminalOutputBox**: Monospace console with copy function
5. **ConfigPanel**: Sliders and inputs for benchmark setup

## 🔧 Troubleshooting

### Flutter Issues
**Problem**: `flutter: command not found`
- Ensure Flutter SDK is in PATH
- Restart terminal after installation

**Problem**: `MissingPluginException`
- Run `flutter clean && flutter pub get`
- Rebuild: `flutter run -d windows`

### Backend Issues
**Problem**: `gcc: command not found`
- Install MinGW-w64 or MSYS2
- Add GCC to PATH: `C:\msys64\mingw64\bin`

**Problem**: `undefined reference to 'omp_get_wtime'`
- OpenMP not linked
- Verify `-fopenmp` flag in Makefile

**Problem**: Segmentation fault
- Problem size too large for RAM
- Reduce size in UI or test with smaller values

### Integration Issues
**Problem**: "Backend executable not found"
- Compile C code first: `cd backend && make all`
- Verify `backend/bin/*.exe` files exist

**Problem**: No data displayed in charts
- Check terminal output box for errors
- Verify JSON output format from C backend

## 📚 Educational Concepts

### Amdahl's Law
```
Speedup = 1 / ((1 - P) + P/N)
```
Where:
- P = Parallel fraction of code
- N = Number of processors

**Key Insight**: Even 5% serial code limits max speedup to 20x.

### False Sharing
Occurs when threads modify variables on the same cache line (typically 64 bytes), causing unnecessary cache invalidations.

**Solution**: Pad data structures or use thread-local variables.

### Dynamic Scheduling
Use `schedule(dynamic)` when workload per iteration varies significantly (e.g., Mandelbrot set).

Static scheduling divides work upfront, which can cause load imbalance.

## 📝 License

Educational use only. Computer Architecture Course Project.

---

**Version**: 1.0.0  
**Course**: Computer Architecture  
**Tech Stack**: Flutter + C/OpenMP  
**Platform**: Windows Desktop
