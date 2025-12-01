# System Information Feature

## Overview
Enhanced system information detection and display for the Parallel Architecture Workbench.

## New Files Created

### Services
- **`lib/services/system_info_service.dart`**
  - `SystemInfoService` - Detects comprehensive hardware specifications
  - `DetailedSystemInfo` - Model for detailed system data
  - `ParallelismGrade` - Enum rating system parallelism capability (Excellent, Very Good, Good, Fair, Poor)
  - `SystemRecommendation` - Hardware-specific optimization suggestions
  - `RecommendationSeverity` - Categorizes recommendations (Info, Warning, Critical)

### Screens
- **`lib/screens/system_info_screen.dart`**
  - Full-screen detailed system information view
  - Sections:
    - System Overview (OS, Architecture, CPU Model)
    - CPU Specifications (Physical/Logical cores, Hyperthreading, Cache line size)
    - Memory Information (Total RAM, Bandwidth considerations)
    - Parallelism Capability Grade (Visual rating with efficiency percentage)
    - Hardware-Specific Recommendations (Context-aware optimization tips)

### Widgets
- **`lib/widgets/hardware_info_badge.dart`** (Modified)
  - Added tap interaction to open `SystemInfoScreen`
  - Added chevron icon to indicate interactivity
  - Maintains compact display in top bar

## Features

### 1. Hardware Detection
- **CPU Information**
  - Physical core count (estimated from logical cores)
  - Logical core count (actual from `Platform.numberOfProcessors`)
  - Hyperthreading detection
  - Architecture (x64, ARM64, x86)
  - Cache line size (64 bytes typical for x86/x64)

- **Memory Information**
  - Total system memory (placeholder 16GB - can be enhanced with FFI)

### 2. Parallelism Grading
Automatic grading based on core count:
- **Excellent**: 16+ logical cores
- **Very Good**: 8-15 logical cores
- **Good**: 4-7 logical cores
- **Fair**: 2-3 logical cores
- **Poor**: 1 logical core

### 3. Smart Recommendations
Context-aware suggestions based on detected hardware:

#### Always Shown
- **Optimal Thread Count**: Recommends using physical cores to avoid hyperthreading overhead
- **False Sharing Risk**: Explains cache line considerations for Matrix Multiplication
- **Amdahl's Law Limit**: Theoretical maximum speedup calculation

#### Conditional
- **Memory Bandwidth Warning** (8+ cores): Explains why memory-bound algorithms plateau
- **Limited Parallelism Warning** (≤2 cores): Suggests testing on higher-core systems
- **NUMA Considerations** (16+ cores): Advises on thread affinity for many-core systems

### 4. Visual Design
- **Color-Coded Grades**: Each parallelism grade has distinct color
  - Excellent: Bright Green (#00FF00)
  - Very Good: Teal (#00D4AA)
  - Good: Amber (#FFB020)
  - Fair: Orange (#FF8800)
  - Poor: Red (#FF4444)

- **Stat Cards**: Modular display for CPU/Memory specs
- **Progress Indicator**: Visual efficiency percentage
- **Circular Grade Badge**: Center-stage parallelism rating
- **Recommendation Cards**: Icon + title + description format

## Usage

### User Flow
1. User sees hardware badge in top-right of app bar
2. Badge shows: "8C / x64" with max speedup
3. User clicks badge → Opens `SystemInfoScreen`
4. Screen displays:
   - Hardware overview
   - Detailed CPU specs
   - Memory information
   - Parallelism grade with visual indicator
   - 5-7 contextual recommendations

### Developer Integration
```dart
// Badge is already integrated in main.dart
HardwareInfoBadge(hardwareInfo: _hardwareInfo)

// To use service directly
final info = await SystemInfoService.getDetailedInfo();
print('Grade: ${info.parallelismGrade.label}');
print('Physical cores: ${info.physicalCores}');
```

## Future Enhancements

### Potential Additions
1. **FFI Integration**: Use platform-specific APIs for accurate memory detection
   - Windows: GlobalMemoryStatusEx
   - Linux: /proc/meminfo
   - macOS: sysctl

2. **Cache Hierarchy**: Detect L1/L2/L3 cache sizes via CPU-ID instructions

3. **Real-Time Monitoring**:
   - CPU temperature (via platform channels)
   - Current CPU usage percentage
   - Memory usage tracking

4. **Benchmark History Correlation**: 
   - Show how hardware impacts actual benchmark results
   - Compare against reference hardware

5. **Export System Report**: 
   - Generate PDF with hardware specs
   - Include benchmark results for documentation

## Technical Notes

### Assumptions
- **Physical Cores**: Estimated as `logicalCores / 2` (assumes hyperthreading on modern CPUs)
- **Cache Line Size**: Hardcoded to 64 bytes (x86/x64 standard)
- **Memory**: Placeholder value (16GB) - needs platform-specific detection

### Architecture Decisions
- **Modular Design**: Service layer separate from UI
- **Future-Proof**: Easy to add FFI for native API calls
- **Educational Focus**: Recommendations explain *why*, not just *what*
- **Consistent Styling**: Matches app's teal/amber dark theme

## Testing Checklist
- [x] Badge clickable and navigates correctly
- [x] Screen displays all sections properly
- [x] Recommendations adapt to core count
- [x] Grade colors display correctly
- [x] No compilation errors
- [ ] Test on different hardware (various core counts)
- [ ] Verify accuracy of detected values
- [ ] Test navigation back button

## Files Modified
1. `lib/widgets/hardware_info_badge.dart` - Added tap handler
2. `lib/screens/screens.dart` - Export new screen
3. `lib/services/services.dart` - Export new service

## Files Created
1. `lib/services/system_info_service.dart` (290 lines)
2. `lib/screens/system_info_screen.dart` (580 lines)
3. `SYSTEM_INFO_FEATURE.md` (this file)
