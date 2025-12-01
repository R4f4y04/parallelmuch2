import '../models/models.dart';

/// Service for managing and analyzing comparison data.
///
/// Handles loading benchmark results, calculating metrics,
/// and providing data for visualization.
class ComparisonService {
  final List<ComparisonSet> _comparisonSets = [];

  /// Get all comparison sets.
  List<ComparisonSet> get allSets => List.unmodifiable(_comparisonSets);

  /// Add a new comparison set from benchmark results.
  ComparisonSet addComparison(String algoName, List<BenchmarkResult> results) {
    final comparisonSet = ComparisonSet.fromResults(algoName, results);
    _comparisonSets.add(comparisonSet);
    return comparisonSet;
  }

  /// Remove a comparison set.
  void removeComparison(String id) {
    _comparisonSets.removeWhere((set) => set.id == id);
  }

  /// Clear all comparison sets.
  void clearAll() {
    _comparisonSets.clear();
  }

  /// Get comparison sets for a specific algorithm.
  List<ComparisonSet> getByAlgorithm(String algoName) {
    return _comparisonSets.where((set) => set.algoName == algoName).toList();
  }

  /// Calculate speedup for a given result against baseline.
  double calculateSpeedup(BenchmarkResult baseline, BenchmarkResult result) {
    if (result.timeSeconds == 0) return 0;
    return baseline.timeSeconds / result.timeSeconds;
  }

  /// Calculate efficiency for a given result.
  double calculateEfficiency(BenchmarkResult baseline, BenchmarkResult result) {
    final speedup = calculateSpeedup(baseline, result);
    return speedup / result.threads;
  }

  /// Generate ideal speedup curve using Amdahl's Law.
  ///
  /// Returns a list of (threads, speedup) pairs for plotting.
  List<MapEntry<int, double>> generateAmdahlCurve(
    ComparisonMetrics metrics,
    int maxThreads,
  ) {
    final points = <MapEntry<int, double>>[];
    for (int t = 1; t <= maxThreads; t++) {
      points.add(MapEntry(t, metrics.amdahlSpeedup(t)));
    }
    return points;
  }

  /// Generate ideal efficiency curve using Amdahl's Law.
  ///
  /// Returns a list of (threads, efficiency) pairs for plotting.
  List<MapEntry<int, double>> generateAmdahlEfficiencyCurve(
    ComparisonMetrics metrics,
    int maxThreads,
  ) {
    final points = <MapEntry<int, double>>[];
    for (int t = 1; t <= maxThreads; t++) {
      points.add(MapEntry(t, metrics.amdahlEfficiency(t)));
    }
    return points;
  }

  /// Export comparison data as CSV string.
  String exportAsCSV(ComparisonSet comparisonSet) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('Algorithm,Timestamp,Threads,Time(s),Speedup,Efficiency');

    final baseline = comparisonSet.baseline;
    if (baseline == null) return buffer.toString();

    // Data rows
    for (final result in comparisonSet.sortedResults) {
      final speedup = calculateSpeedup(baseline, result);
      final efficiency = calculateEfficiency(baseline, result);

      buffer.writeln(
        '${comparisonSet.algoName},'
        '${comparisonSet.timestamp.toIso8601String()},'
        '${result.threads},'
        '${result.timeSeconds.toStringAsFixed(4)},'
        '${speedup.toStringAsFixed(2)},'
        '${efficiency.toStringAsFixed(2)}',
      );
    }

    // Add metrics summary
    buffer.writeln();
    buffer.writeln('Metrics Summary');
    buffer.writeln(
      'Average Speedup,${comparisonSet.metrics.averageSpeedup.toStringAsFixed(2)}',
    );
    buffer.writeln(
      'Average Efficiency,${comparisonSet.metrics.averageEfficiency.toStringAsFixed(2)}',
    );
    buffer.writeln(
      'Max Speedup,${comparisonSet.metrics.maxSpeedup.toStringAsFixed(2)}',
    );
    buffer.writeln(
      'Optimal Threads,${comparisonSet.metrics.optimalThreadCount}',
    );
    buffer.writeln(
      'Serial Fraction,${comparisonSet.metrics.serialFraction.toStringAsFixed(4)}',
    );

    return buffer.toString();
  }

  /// Export all comparison sets as JSON string.
  String exportAllAsJSON() {
    final buffer = StringBuffer();
    buffer.writeln('[');

    for (int i = 0; i < _comparisonSets.length; i++) {
      final set = _comparisonSets[i];
      buffer.writeln('  {');
      buffer.writeln('    "id": "${set.id}",');
      buffer.writeln('    "algoName": "${set.algoName}",');
      buffer.writeln('    "timestamp": "${set.timestamp.toIso8601String()}",');
      buffer.writeln('    "results": [');

      for (int j = 0; j < set.results.length; j++) {
        final result = set.results[j];
        buffer.write(
          '      {"threads": ${result.threads}, "time": ${result.timeSeconds}}',
        );
        if (j < set.results.length - 1) buffer.write(',');
        buffer.writeln();
      }

      buffer.writeln('    ],');
      buffer.writeln('    "metrics": {');
      buffer.writeln('      "averageSpeedup": ${set.metrics.averageSpeedup},');
      buffer.writeln(
        '      "averageEfficiency": ${set.metrics.averageEfficiency},',
      );
      buffer.writeln('      "maxSpeedup": ${set.metrics.maxSpeedup},');
      buffer.writeln(
        '      "optimalThreadCount": ${set.metrics.optimalThreadCount},',
      );
      buffer.writeln('      "serialFraction": ${set.metrics.serialFraction}');
      buffer.writeln('    }');
      buffer.write('  }');
      if (i < _comparisonSets.length - 1) buffer.write(',');
      buffer.writeln();
    }

    buffer.writeln(']');
    return buffer.toString();
  }
}
