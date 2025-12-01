/// Result of a single benchmark execution.
///
/// Represents the output from a C backend executable, parsed from JSON stdout.
class BenchmarkResult {
  final String algoId;
  final int threads;
  final int problemSize;
  final double timeSeconds;
  final DateTime timestamp;

  // Derived metrics
  final double? speedup; // Relative to serial execution
  final double? efficiency; // Speedup / Threads

  const BenchmarkResult({
    required this.algoId,
    required this.threads,
    required this.problemSize,
    required this.timeSeconds,
    required this.timestamp,
    this.speedup,
    this.efficiency,
  });

  /// Parse from JSON output of C backend
  /// Expected format: {"algo": "matrix_mult", "threads": 8, "size": 1024, "time": 0.452}
  factory BenchmarkResult.fromJson(
    Map<String, dynamic> json, {
    double? baselineTime,
  }) {
    final threads = json['threads'] as int;
    final timeSeconds = (json['time'] as num).toDouble();

    double? speedup;
    double? efficiency;

    if (baselineTime != null && baselineTime > 0) {
      speedup = baselineTime / timeSeconds;
      efficiency = speedup / threads;
    }

    return BenchmarkResult(
      algoId: json['algo'] as String,
      threads: threads,
      problemSize: json['size'] as int,
      timeSeconds: timeSeconds,
      timestamp: DateTime.now(),
      speedup: speedup,
      efficiency: efficiency,
    );
  }

  /// Convert to JSON for serialization/storage
  Map<String, dynamic> toJson() => {
    'algo': algoId,
    'threads': threads,
    'size': problemSize,
    'time': timeSeconds,
    'timestamp': timestamp.toIso8601String(),
    if (speedup != null) 'speedup': speedup,
    if (efficiency != null) 'efficiency': efficiency,
  };

  /// Copy with modified fields
  BenchmarkResult copyWith({
    String? algoId,
    int? threads,
    int? problemSize,
    double? timeSeconds,
    DateTime? timestamp,
    double? speedup,
    double? efficiency,
  }) {
    return BenchmarkResult(
      algoId: algoId ?? this.algoId,
      threads: threads ?? this.threads,
      problemSize: problemSize ?? this.problemSize,
      timeSeconds: timeSeconds ?? this.timeSeconds,
      timestamp: timestamp ?? this.timestamp,
      speedup: speedup ?? this.speedup,
      efficiency: efficiency ?? this.efficiency,
    );
  }

  @override
  String toString() =>
      'BenchmarkResult(algo: $algoId, threads: $threads, time: ${timeSeconds.toStringAsFixed(4)}s, speedup: ${speedup?.toStringAsFixed(2) ?? "N/A"})';
}

/// Collection of benchmark results for analysis
class BenchmarkSuite {
  final String algoId;
  final int problemSize;
  final List<BenchmarkResult> results;
  final BenchmarkResult? serialBaseline; // Single-threaded execution

  const BenchmarkSuite({
    required this.algoId,
    required this.problemSize,
    required this.results,
    this.serialBaseline,
  });

  /// Calculate speedup for all results relative to baseline
  List<BenchmarkResult> get resultsWithSpeedup {
    if (serialBaseline == null) return results;

    final baselineTime = serialBaseline!.timeSeconds;
    return results.map((r) {
      if (r.speedup != null) return r;

      final speedup = baselineTime / r.timeSeconds;
      final efficiency = speedup / r.threads;

      return r.copyWith(speedup: speedup, efficiency: efficiency);
    }).toList();
  }

  /// Get maximum observed speedup
  double? get maxSpeedup {
    final withSpeedup = resultsWithSpeedup
        .where((r) => r.speedup != null)
        .map((r) => r.speedup!);

    return withSpeedup.isEmpty
        ? null
        : withSpeedup.reduce((a, b) => a > b ? a : b);
  }

  /// Get average efficiency across all thread counts
  double? get avgEfficiency {
    final efficiencies = resultsWithSpeedup
        .where((r) => r.efficiency != null)
        .map((r) => r.efficiency!);

    if (efficiencies.isEmpty) return null;
    return efficiencies.reduce((a, b) => a + b) / efficiencies.length;
  }
}
