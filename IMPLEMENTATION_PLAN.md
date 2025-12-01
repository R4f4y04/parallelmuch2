# Implementation Plan: Code Viewer & Sequential vs Parallel Comparison

## 📋 Overview

This document outlines the implementation plan for two major features:
1. **Code Viewer**: Side-by-side serial vs parallel code with annotations
2. **Sequential vs Parallel Comparison**: Visual performance comparison tool

---

## 🎯 Feature 1: Code Viewer

### User Flow
1. User clicks algorithm card from dashboard
2. Instead of "Configure" button → **"View Code"** button
3. Opens full-screen code viewer with split view:
   - **Left Panel**: Serial implementation (pseudocode or actual C)
   - **Right Panel**: Parallel implementation (actual C with OpenMP)
   - **Annotations**: Highlighted differences with educational tooltips

### UI Design

#### Layout Structure
```
┌─────────────────────────────────────────────────────────┐
│  [←] Matrix Multiplication                    [⚙ Run]  │ ← App Bar
├──────────────────────┬──────────────────────────────────┤
│   SERIAL VERSION     │     PARALLEL VERSION             │
│  ┌─────────────────┐│┌───────────────────────────────┐ │
│  │ // Sequential   ││││ // Parallel with OpenMP      │ │
│  │ for (i=0...)    ││││ #pragma omp parallel for      │ │
│  │   for (j=0...)  ││││ for (i=0...) {               │ │
│  │     compute()   ││││   for (j=0...)                │ │
│  │                 ││││     compute()                  │ │
│  └─────────────────┘│└───────────────────────────────┘ │
│                      │                                   │
│  [Complexity: O(N³)] │ [Speedup Potential: ~8x]         │
├──────────────────────┴──────────────────────────────────┤
│  📝 Key Differences & Annotations                        │
│  ┌─────────────────────────────────────────────────┐   │
│  │ • Line 5: OpenMP directive parallelizes loop    │   │
│  │ • False sharing risk on adjacent writes         │   │
│  │ • Static scheduling for uniform workload        │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

### Implementation Details

#### A. New Files to Create

**1. `lib/models/code_snippet.dart`**
```dart
class CodeSnippet {
  final String algoId;
  final String serialCode;
  final String parallelCode;
  final List<CodeAnnotation> annotations;
  final Map<int, String> serialLineComments;  // Line number → Comment
  final Map<int, String> parallelLineComments;
  final List<CodeHighlight> highlights;  // Highlight regions
}

class CodeAnnotation {
  final String title;
  final String description;
  final int serialLineStart;
  final int parallelLineStart;
  final AnnotationType type;  // optimization, warning, concept
  final IconData icon;
}

class CodeHighlight {
  final int lineNumber;
  final CodeSide side;  // serial or parallel
  final Color color;
  final String tooltip;
}

enum CodeSide { serial, parallel }
enum AnnotationType { optimization, warning, concept, difference }
```

**2. `lib/services/code_snippet_service.dart`**
- Static service providing code snippets for each algorithm
- Hardcoded serial/parallel implementations with annotations
- Methods:
  - `getCodeSnippet(String algoId)` → Returns CodeSnippet
  - `_generateMatrixMultCode()` → Matrix multiplication snippets
  - `_generateMergeSortCode()` → Merge sort snippets
  - etc. for all 5 algorithms

**3. `lib/screens/code_viewer_screen.dart`**
- Full-screen split view
- Features:
  - Syntax highlighting using `flutter_highlight` package
  - Synchronized scrolling (both panels scroll together)
  - Line numbers
  - Hoverable line annotations
  - Copy code buttons
  - Export both versions
  - "Run Benchmark" button in app bar

**4. `lib/widgets/code_panel.dart`**
- Reusable code display panel
- Supports:
  - Syntax highlighting (C language)
  - Line numbers with custom styling
  - Inline comment badges
  - Clickable highlights for tooltips
  - Monospace font (JetBrains Mono)

**5. `lib/widgets/annotation_card.dart`**
- Displays code annotation details
- Shows diff between serial/parallel
- Color-coded by type
- Expandable for detailed explanation

#### B. Dependencies to Add

```yaml
# pubspec.yaml additions
dependencies:
  flutter_highlight: ^0.7.0  # Syntax highlighting
  highlight: ^0.7.0  # Language definitions
```

#### C. Button Replacement Strategy

**Current**: AlgoCard has "Configure" button
**New**: Replace with "View Code" button

```dart
// In algo_card.dart
TextButton.icon(
  onPressed: onViewCode,  // New callback
  icon: const Icon(Icons.code, size: 18),
  label: const Text('View Code'),
)
```

**Navigation Flow Update** (in `main.dart`):
```dart
// Old: onAlgoSelected → ExecutionScreen
// New: onAlgoSelected → CodeViewerScreen
// Add: FloatingActionButton in CodeViewerScreen → ExecutionScreen
```

#### D. Code Content Strategy

**Option 1: Simplified Pseudocode** (Recommended for clarity)
- Serial: Clean, educational pseudocode
- Parallel: Real C code from backend files
- Easier to understand, focuses on concepts

**Option 2: Actual C Code**
- Serial: Strip OpenMP pragmas from parallel code
- Parallel: Read directly from backend/*.c files
- More authentic, shows real implementation

**Recommendation**: Use Option 1 with simplified serial code for educational clarity.

---

## 🎯 Feature 2: Sequential vs Parallel Comparison

### User Flow
1. User accesses comparison tool from:
   - **Option A**: New navigation tab "Comparison"
   - **Option B**: Button in dashboard header
   - **Option C**: Tab within execution screen
2. User selects algorithm
3. Configures problem sizes (e.g., 100, 500, 1000, 5000)
4. Clicks "Run Comparison"
5. System executes:
   - Serial (1 thread) for each size
   - Parallel (optimal threads) for each size
6. Displays visualizations:
   - Execution time comparison (bar chart)
   - Speedup curve
   - Efficiency graph
   - Time savings calculation

### UI Design

#### Layout Structure
```
┌──────────────────────────────────────────────────────────┐
│  Sequential vs Parallel Comparison                       │
├──────────────────────────────────────────────────────────┤
│  ┌────────────────────────────────────────────────────┐  │
│  │ Algorithm: [Matrix Multiplication ▼]              │  │
│  │ Problem Sizes: [256, 512, 1024, 2048]             │  │
│  │ Parallel Threads: [8] (Auto-detected)             │  │
│  │                                    [Run Analysis]  │  │
│  └────────────────────────────────────────────────────┘  │
├──────────────────────────────────────────────────────────┤
│  📊 Execution Time Comparison                            │
│  ┌────────────────────────────────────────────────────┐  │
│  │    Time (seconds)                                   │  │
│  │  4 │█████████ Serial                                │  │
│  │  3 │█████████                                        │  │
│  │  2 │████████ Parallel                                │  │
│  │  1 │████                                             │  │
│  │  0 │____________________________________             │  │
│  │     256   512   1024  2048  (Problem Size)          │  │
│  └────────────────────────────────────────────────────┘  │
│                                                           │
│  📈 Speedup Analysis                                      │
│  ┌────────────────────────────────────────────────────┐  │
│  │  Speedup                                             │  │
│  │  8x│                              ●────● Observed   │  │
│  │  6x│                        ●────●                   │  │
│  │  4x│                  ●────●                         │  │
│  │  2x│           ●─────●                               │  │
│  │  1x│●──────────────────────────── Ideal             │  │
│  │     256   512   1024  2048  (Problem Size)          │  │
│  └────────────────────────────────────────────────────┘  │
│                                                           │
│  💾 Summary Statistics                                    │
│  ┌─────────────────────┬──────────────────────────────┐  │
│  │ Average Speedup     │ 6.2x                         │  │
│  │ Total Time Saved    │ 12.4 seconds                 │  │
│  │ Best Performance    │ 2048 size (7.8x speedup)     │  │
│  │ Efficiency          │ 77.5% (of theoretical max)   │  │
│  └─────────────────────┴──────────────────────────────┘  │
└──────────────────────────────────────────────────────────┘
```

### Implementation Details

#### A. New Files to Create

**1. `lib/models/comparison_config.dart`**
```dart
class ComparisonConfig {
  final String algoId;
  final List<int> problemSizes;
  final int parallelThreads;
  final bool includeMultipleThreadCounts;  // Optional: test 2,4,8 threads
}

class ComparisonResult {
  final String algoId;
  final List<ComparisonDataPoint> dataPoints;
  final ComparisonStats stats;
}

class ComparisonDataPoint {
  final int problemSize;
  final double serialTime;
  final double parallelTime;
  final double speedup;
  final double efficiency;
  final double timeSaved;
}

class ComparisonStats {
  final double avgSpeedup;
  final double totalTimeSaved;
  final ComparisonDataPoint bestPerformance;
  final double avgEfficiency;
}
```

**2. `lib/screens/comparison_screen.dart`**
- Main comparison interface
- Sections:
  - Configuration panel (algorithm, sizes, threads)
  - Execution progress indicator
  - Results display (charts + stats)
  - Export/share functionality

**3. `lib/widgets/comparison_chart.dart`**
- Reusable chart widget for comparison data
- Types:
  - Grouped bar chart (serial vs parallel)
  - Line chart (speedup curve)
  - Stacked area (cumulative time saved)
- Uses `fl_chart` package (already in dependencies)

**4. `lib/widgets/comparison_config_panel.dart`**
- Configuration UI for comparison runs
- Features:
  - Algorithm dropdown
  - Problem size chips (add/remove)
  - Thread count slider
  - "Run Analysis" button
  - Presets (Quick, Detailed, Custom)

**5. `lib/widgets/comparison_stats_card.dart`**
- Summary statistics display
- Metrics:
  - Average speedup
  - Total time saved
  - Best/worst performing size
  - Efficiency percentage

**6. `lib/services/comparison_service.dart`**
- Orchestrates comparison benchmarks
- Methods:
  - `runComparison(ComparisonConfig)` → ComparisonResult
  - `_runSerial(algoId, size)` → BenchmarkResult
  - `_runParallel(algoId, size, threads)` → BenchmarkResult
  - `_calculateStats(List<ComparisonDataPoint>)` → ComparisonStats
- Uses existing `ProcessRunnerService` internally

#### B. Navigation Integration

**Recommended Approach: New Tab in Main Navigation**

Update `lib/main.dart`:
```dart
// Add third tab in MainShell
NavigationRailDestination(
  icon: Icon(Icons.compare_arrows),
  label: Text('Comparison'),
)

// Update _buildContent()
case 2:
  return ComparisonScreen();
```

**Alternative: Dashboard Integration**
- Add button in dashboard header: "Sequential vs Parallel Analysis"
- Opens comparison screen as modal or new route
- Keeps main navigation clean (2 tabs)

**Recommendation**: Add as 3rd navigation tab for equal prominence.

#### C. Chart Visualizations

**1. Execution Time Comparison** (Grouped Bar Chart)
- X-axis: Problem sizes
- Y-axis: Time in seconds
- Two bars per size (Serial = Red, Parallel = Teal)
- Shows absolute performance difference

**2. Speedup Analysis** (Line Chart)
- X-axis: Problem sizes
- Y-axis: Speedup multiplier
- Line showing observed speedup
- Dotted reference line at ideal (linear scaling)
- Highlights scaling behavior

**3. Time Saved** (Stacked Area Chart - Optional)
- Cumulative time savings across sizes
- Visual representation of total benefit
- Fills area under the savings curve

**4. Efficiency Heatmap** (Optional Advanced Feature)
- 2D grid: Problem Size × Thread Count
- Color intensity = Efficiency percentage
- Shows optimal operating points

#### D. Execution Strategy

**Sequential Execution** (for accurate timing):
```
1. Run serial (1 thread) for size[0]
2. Run parallel (N threads) for size[0]
3. Repeat for size[1], size[2], etc.
4. Show progress: "Running 3/8 benchmarks..."
```

**Parallel Execution** (faster but less accurate):
```
Run all serial tests → Run all parallel tests
Risk: System load affects timing
Benefit: 50% faster execution
```

**Recommendation**: Sequential execution for accuracy.

---

## 📁 File Structure Summary

### New Directories
```
lib/
├── models/
│   ├── code_snippet.dart          (NEW)
│   └── comparison_config.dart     (NEW)
├── screens/
│   ├── code_viewer_screen.dart    (NEW)
│   └── comparison_screen.dart     (NEW)
├── widgets/
│   ├── code_panel.dart            (NEW)
│   ├── annotation_card.dart       (NEW)
│   ├── comparison_chart.dart      (NEW)
│   ├── comparison_config_panel.dart (NEW)
│   └── comparison_stats_card.dart (NEW)
└── services/
    ├── code_snippet_service.dart  (NEW)
    └── comparison_service.dart    (NEW)
```

### Files to Modify
```
lib/
├── main.dart                       (Add 3rd nav tab)
├── models/models.dart              (Export new models)
├── screens/screens.dart            (Export new screens)
├── widgets/widgets.dart            (Export new widgets)
├── widgets/algo_card.dart          (Replace Configure → View Code)
└── screens/dashboard_screen.dart   (Update callback)
```

---

## 🔧 Implementation Phases

### Phase 1: Code Viewer (Priority 1)
**Estimated Time**: 4-6 hours

1. **Setup** (30 min)
   - Add `flutter_highlight` dependency
   - Create model files
   - Update barrel exports

2. **Code Snippet Service** (2 hours)
   - Create service with 5 algorithm snippets
   - Write annotations for each
   - Add inline comments

3. **Code Viewer Screen** (2 hours)
   - Build split-view layout
   - Implement syntax highlighting
   - Add synchronized scrolling
   - Create annotation display

4. **Widget Updates** (1 hour)
   - Replace "Configure" → "View Code"
   - Update navigation flow
   - Add "Run Benchmark" button in viewer

5. **Testing & Polish** (30 min)
   - Test all 5 algorithms
   - Verify annotations display
   - Check responsive layout

### Phase 2: Comparison Tool (Priority 2)
**Estimated Time**: 5-7 hours

1. **Models & Service** (2 hours)
   - Create comparison models
   - Implement comparison service
   - Add progress tracking

2. **Configuration Panel** (1.5 hours)
   - Build config UI
   - Add presets
   - Implement validation

3. **Visualization Widgets** (2 hours)
   - Create bar chart
   - Create speedup line chart
   - Add stats cards

4. **Comparison Screen** (1.5 hours)
   - Assemble full screen
   - Wire up execution flow
   - Add loading states

5. **Navigation Integration** (1 hour)
   - Add 3rd tab to main nav
   - Update routing
   - Test navigation flow

---

## 🎨 Design Consistency

### Color Scheme (Maintain Existing)
- **Primary**: Teal (#00D4AA) - Parallel bars, speedup lines
- **Tertiary**: Amber (#FFB020) - Serial bars, warnings
- **Background**: Dark (#0D1117, #161B22)
- **Accent**: Red/Orange for serial execution emphasis

### Typography
- **Code**: JetBrains Mono (monospace)
- **Headers**: Inter Bold
- **Body**: Inter Regular
- **Line Numbers**: 80% opacity, smaller size

### Icons
- **View Code**: `Icons.code`
- **Comparison**: `Icons.compare_arrows`
- **Serial**: `Icons.looks_one`
- **Parallel**: `Icons.apps`
- **Speedup**: `Icons.trending_up`

---

## 🧪 Testing Checklist

### Code Viewer
- [ ] All 5 algorithms load correctly
- [ ] Syntax highlighting works
- [ ] Annotations are accurate
- [ ] Synchronized scrolling
- [ ] Copy code functionality
- [ ] Navigate to execution screen
- [ ] Responsive on different window sizes

### Comparison Tool
- [ ] Serial execution accurate
- [ ] Parallel execution accurate
- [ ] Charts render correctly
- [ ] Stats calculations accurate
- [ ] Progress indicator works
- [ ] Multiple algorithms tested
- [ ] Edge cases (very small/large sizes)
- [ ] Export functionality

---

## 💡 Future Enhancements

### Code Viewer Extensions
1. **Diff View Mode**: Show only changed lines
2. **Execution Trace**: Animate how threads execute
3. **Interactive Annotations**: Click to expand details
4. **Code Export**: Generate PDF with annotations
5. **Custom Snippets**: Allow user-provided code

### Comparison Extensions
1. **Multi-Algorithm Comparison**: Compare Matrix Mult vs Merge Sort scaling
2. **Historical Tracking**: Save past comparison runs
3. **Hardware Comparison**: Compare results across different systems
4. **3D Visualization**: Size × Threads × Time surface plot
5. **AI Insights**: Automated analysis and recommendations

---

## 📝 Code Snippet Preview Examples

### Matrix Multiplication

**Serial** (Simplified):
```c
// Sequential matrix multiplication
// Time Complexity: O(N³)
void matrix_mult_serial(double* A, double* B, double* C, int N) {
    for (int i = 0; i < N; i++) {           // ← Row iteration
        for (int j = 0; j < N; j++) {       // ← Column iteration
            double sum = 0.0;
            for (int k = 0; k < N; k++) {   // ← Dot product
                sum += A[i*N + k] * B[k*N + j];
            }
            C[i*N + j] = sum;
        }
    }
}
// Memory Access: Sequential, predictable
// Cache Efficiency: Good spatial locality
```

**Parallel**:
```c
// Parallel matrix multiplication with OpenMP
// Expected Speedup: ~6-8x on 8 cores
void matrix_mult_parallel(double* A, double* B, double* C, int N, int threads) {
    omp_set_num_threads(threads);
    
    #pragma omp parallel for schedule(static)  // ← PARALLELIZATION
    for (int i = 0; i < N; i++) {              // ← Each thread gets rows
        for (int j = 0; j < N; j++) {          
            double sum = 0.0;                   // ← Thread-local variable
            for (int k = 0; k < N; k++) {      
                sum += A[i*N + k] * B[k*N + j];
            }
            C[i*N + j] = sum;                   // ← Potential false sharing!
        }
    }
}
// Scheduling: Static (uniform workload)
// Risk: False sharing on adjacent row writes (64-byte cache lines)
```

**Annotations**:
1. **Line 7**: OpenMP directive distributes iterations across threads
2. **Scheduling Strategy**: Static scheduling optimal for uniform workload
3. **Memory Consideration**: Adjacent rows may share cache lines → false sharing
4. **Speedup Limitation**: Memory bandwidth becomes bottleneck at high thread counts

---

## 🚀 Recommended Implementation Order

1. ✅ **Start with Code Viewer** - More straightforward, immediate educational value
2. ✅ **Then Comparison Tool** - Builds on existing benchmark infrastructure
3. ✅ **Polish Both** - Refinements, responsive design, edge cases
4. ✅ **Documentation** - Update README, QUICKSTART with new features

---

## 📊 Success Metrics

### Code Viewer
- Users can understand parallel concepts from annotations
- Clear visualization of serial → parallel transformation
- All 5 algorithms have comprehensive snippets

### Comparison Tool
- Accurate timing data (±5% variance acceptable)
- Clear visualization of speedup trends
- Immediate educational insights from charts

---

## 🔗 Integration Points

### With Existing Features
- **System Info**: Use detected core count for comparison defaults
- **Execution Screen**: Link from code viewer ("Run This Code")
- **Dashboard**: Maintain cohesive navigation
- **Backend**: Reuse existing `ProcessRunnerService`

### Data Flow
```
User Input → ComparisonService → ProcessRunnerService → C Executables
                ↓
         ComparisonResult → Visualization Widgets → User Display
```

---

This implementation plan provides a complete roadmap for both features while maintaining code modularity, design consistency, and educational value. The phased approach allows for incremental development and testing.
