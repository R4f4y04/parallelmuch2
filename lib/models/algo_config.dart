/// Configuration and metadata for a parallel algorithm workload.
///
/// Each algorithm demonstrates specific architectural concepts in parallel computing.
class AlgoConfig {
  final String id;
  final String name;
  final String description;
  final String complexity; // e.g., "O(N³)", "O(N²)", "O(N)"
  final List<String> tags; // e.g., ["Cache Coherence", "Memory Bound"]
  final String executableName; // e.g., "matrix_mult.exe"
  final IconType iconType;
  final int defaultSize;
  final int minSize;
  final int maxSize;
  final int sizeStep;

  const AlgoConfig({
    required this.id,
    required this.name,
    required this.description,
    required this.complexity,
    required this.tags,
    required this.executableName,
    required this.iconType,
    this.defaultSize = 1024,
    this.minSize = 128,
    this.maxSize = 4096,
    this.sizeStep = 128,
  });

  /// Predefined algorithm configurations for the workbench
  static const List<AlgoConfig> allAlgorithms = [
    AlgoConfig(
      id: 'matrix_mult',
      name: 'Matrix Multiplication',
      description: 'Demonstrates cache coherence and memory access patterns',
      complexity: 'O(N³)',
      tags: ['Cache Coherence', 'Memory Bound', 'False Sharing Risk'],
      executableName: 'matrix_mult.exe',
      iconType: IconType.matrix,
      defaultSize: 1024,
      maxSize: 2048,
    ),
    AlgoConfig(
      id: 'merge_sort',
      name: 'Merge Sort',
      description: 'Recursive parallelism and memory bandwidth saturation',
      complexity: 'O(N log N)',
      tags: ['Recursive Parallelism', 'Memory Bandwidth', 'Task-based'],
      executableName: 'merge_sort.exe',
      iconType: IconType.sort,
      defaultSize: 10000000,
      minSize: 1000000,
      maxSize: 50000000,
      sizeStep: 1000000,
    ),
    AlgoConfig(
      id: 'monte_carlo',
      name: 'Monte Carlo (π Estimation)',
      description: 'Embarrassingly parallel with atomic operations',
      complexity: 'O(N)',
      tags: ['Embarrassingly Parallel', 'CPU Bound', 'Atomic Operations'],
      executableName: 'monte_carlo.exe',
      iconType: IconType.random,
      defaultSize: 100000000,
      minSize: 10000000,
      maxSize: 1000000000,
      sizeStep: 10000000,
    ),
    AlgoConfig(
      id: 'nbody',
      name: 'N-Body Simulation',
      description: 'Quadratic complexity with fine-grained parallelism',
      complexity: 'O(N²)',
      tags: ['Fine-grained', 'CPU Bound', 'Computational Physics'],
      executableName: 'nbody.exe',
      iconType: IconType.physics,
      defaultSize: 5000,
      minSize: 1000,
      maxSize: 20000,
      sizeStep: 1000,
    ),
    AlgoConfig(
      id: 'mandelbrot',
      name: 'Mandelbrot Set',
      description: 'Load imbalance and dynamic scheduling',
      complexity: 'O(N² × k)',
      tags: ['Load Imbalance', 'Dynamic Scheduling', 'Embarrassingly Parallel'],
      executableName: 'mandelbrot.exe',
      iconType: IconType.fractal,
      defaultSize: 2048,
      minSize: 512,
      maxSize: 4096,
      sizeStep: 512,
    ),
  ];

  /// Get algorithm by ID
  static AlgoConfig? getById(String id) {
    try {
      return allAlgorithms.firstWhere((algo) => algo.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// Icon types for visual representation of algorithms
enum IconType { matrix, sort, random, physics, fractal }
