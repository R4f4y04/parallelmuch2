import 'benchmark_result.dart';

/// A set of benchmark results for comparison analysis.
///
/// Contains results from multiple runs to compare sequential vs parallel
/// performance, efficiency, and speedup characteristics.
class ComparisonSet {
  final String id;
  final String algoName;
  final DateTime timestamp;
  final List<BenchmarkResult> results;
  final ComparisonMetrics metrics;

  const ComparisonSet({
    required this.id,
    required this.algoName,
    required this.timestamp,
    required this.results,
    required this.metrics,
  });

  /// Create a comparison set from benchmark results.
  factory ComparisonSet.fromResults(
    String algoName,
    List<BenchmarkResult> results,
  ) {
    final metrics = ComparisonMetrics.calculate(results);
    return ComparisonSet(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      algoName: algoName,
      timestamp: DateTime.now(),
      results: results,
      metrics: metrics,
    );
  }

  /// Get the baseline (serial/1-thread) result.
  BenchmarkResult? get baseline {
    return results.firstWhere(
      (r) => r.threads == 1,
      orElse: () => results.first,
    );
  }

  /// Get results sorted by thread count.
  List<BenchmarkResult> get sortedResults {
    final sorted = List<BenchmarkResult>.from(results);
    sorted.sort((a, b) => a.threads.compareTo(b.threads));
    return sorted;
  }
}

/// Calculated metrics for comparison analysis.
///
/// Provides efficiency, speedup, and Amdahl's Law projections.
class ComparisonMetrics {
  final double averageSpeedup;
  final double averageEfficiency;
  final double maxSpeedup;
  final double minEfficiency;
  final double serialFraction; // For Amdahl's Law
  final int optimalThreadCount;

  const ComparisonMetrics({
    required this.averageSpeedup,
    required this.averageEfficiency,
    required this.maxSpeedup,
    required this.minEfficiency,
    required this.serialFraction,
    required this.optimalThreadCount,
  });

  /// Calculate metrics from benchmark results.
  factory ComparisonMetrics.calculate(List<BenchmarkResult> results) {
    if (results.isEmpty) {
      return const ComparisonMetrics(
        averageSpeedup: 0,
        averageEfficiency: 0,
        maxSpeedup: 0,
        minEfficiency: 0,
        serialFraction: 1.0,
        optimalThreadCount: 1,
      );
    }

    // Find baseline (1 thread or first result)
    final baseline = results.firstWhere(
      (r) => r.threads == 1,
      orElse: () => results.first,
    );

    double totalSpeedup = 0;
    double totalEfficiency = 0;
    double maxSpeedup = 0;
    double minEfficiency = double.infinity;
    int optimalThreads = 1;
    double bestEfficiency = 0;

    for (final result in results) {
      if (result.threads == baseline.threads) continue;

      final speedup = baseline.timeSeconds / result.timeSeconds;
      final efficiency = speedup / result.threads;

      totalSpeedup += speedup;
      totalEfficiency += efficiency;

      if (speedup > maxSpeedup) {
        maxSpeedup = speedup;
      }

      if (efficiency < minEfficiency) {
        minEfficiency = efficiency;
      }

      // Track optimal thread count (best efficiency)
      if (efficiency > bestEfficiency) {
        bestEfficiency = efficiency;
        optimalThreads = result.threads;
      }
    }

    final count = results.length - 1; // Exclude baseline
    final avgSpeedup = count > 0 ? totalSpeedup / count : 0;
    final avgEfficiency = count > 0 ? totalEfficiency / count : 0;

    // Estimate serial fraction using Amdahl's Law
    // S = 1 / (f + (1-f)/N) => f ≈ (1/S - 1/N) / (1 - 1/N)
    double serialFraction = 0;
    if (maxSpeedup > 0 && results.length > 1) {
      final bestResult = results.reduce(
        (a, b) =>
            (baseline.timeSeconds / a.timeSeconds) >
                (baseline.timeSeconds / b.timeSeconds)
            ? a
            : b,
      );
      final n = bestResult.threads.toDouble();
      final s = baseline.timeSeconds / bestResult.timeSeconds;
      serialFraction = ((1 / s) - (1 / n)) / (1 - (1 / n));
      serialFraction = serialFraction.clamp(0.0, 1.0);
    }

    return ComparisonMetrics(
      averageSpeedup: avgSpeedup.toDouble(),
      averageEfficiency: avgEfficiency.toDouble(),
      maxSpeedup: maxSpeedup,
      minEfficiency: minEfficiency == double.infinity ? 0 : minEfficiency,
      serialFraction: serialFraction,
      optimalThreadCount: optimalThreads,
    );
  }

  /// Calculate ideal speedup based on Amdahl's Law.
  double amdahlSpeedup(int threads) {
    final t = threads.toDouble();
    return 1 / (serialFraction + (1 - serialFraction) / t);
  }

  /// Calculate ideal efficiency based on Amdahl's Law.
  double amdahlEfficiency(int threads) {
    return amdahlSpeedup(threads) / threads.toDouble();
  }
}
