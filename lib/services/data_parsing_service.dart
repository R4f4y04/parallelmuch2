import 'dart:convert';
import '../models/models.dart';

/// Service for parsing and validating data from backend C processes.
///
/// Handles JSON parsing with error recovery and validation.
class DataParsingService {
  /// Parse a single JSON result from C backend
  ///
  /// Expected format: {"algo": "matrix_mult", "threads": 8, "size": 1024, "time": 0.452}
  static BenchmarkResult parseResult(
    String jsonString, {
    double? baselineTime,
  }) {
    try {
      final data = jsonDecode(jsonString.trim()) as Map<String, dynamic>;
      return BenchmarkResult.fromJson(data, baselineTime: baselineTime);
    } catch (e) {
      throw FormatException(
        'Failed to parse benchmark result: $e\nInput: $jsonString',
      );
    }
  }

  /// Parse multiple JSON results from concatenated output
  ///
  /// Handles cases where multiple executions output JSON on separate lines.
  static List<BenchmarkResult> parseMultipleResults(String output) {
    final results = <BenchmarkResult>[];
    final lines = output.split('\n').where((line) => line.trim().isNotEmpty);

    for (final line in lines) {
      try {
        if (line.trim().startsWith('{') && line.trim().endsWith('}')) {
          results.add(parseResult(line));
        }
      } catch (e) {
        // Skip lines that aren't valid JSON (e.g., debug output)
        continue;
      }
    }

    return results;
  }

  /// Validate that a benchmark result is reasonable
  ///
  /// Performs sanity checks on timing data.
  static bool validateResult(BenchmarkResult result) {
    // Time must be positive
    if (result.timeSeconds <= 0) return false;

    // Speedup cannot exceed thread count significantly (super-linear speedup is rare)
    if (result.speedup != null && result.speedup! > result.threads * 1.5) {
      return false; // Suspicious
    }

    // Efficiency should be between 0 and 1 (with some tolerance)
    if (result.efficiency != null &&
        (result.efficiency! < 0 || result.efficiency! > 1.2)) {
      return false;
    }

    return true;
  }

  /// Extract error information from stderr
  ///
  /// Parses common C runtime errors (segfault, malloc failures, etc.)
  static String parseError(String stderr) {
    if (stderr.isEmpty) return 'Unknown error';

    // Common patterns
    if (stderr.contains('Segmentation fault') || stderr.contains('SIGSEGV')) {
      return 'Segmentation fault: Memory access violation detected in C code';
    }
    if (stderr.contains('malloc') || stderr.contains('Out of memory')) {
      return 'Memory allocation failure: Problem size may be too large';
    }
    if (stderr.contains('cannot allocate')) {
      return 'Resource allocation failed: Insufficient system resources';
    }
    if (stderr.contains('Permission denied')) {
      return 'Permission denied: Cannot execute backend binary';
    }

    // Return first line of stderr if nothing matches
    return stderr.split('\n').first;
  }

  /// Calculate ideal speedup for comparison
  ///
  /// Returns a list of ideal linear speedup values for plotting.
  static List<double> calculateIdealSpeedup(List<int> threadCounts) {
    return threadCounts.map((threads) => threads.toDouble()).toList();
  }

  /// Calculate Amdahl's Law theoretical speedup
  ///
  /// S(p) = 1 / ((1 - P) + P/p)
  /// where P is the parallel fraction, p is the number of processors
  static double amdahlSpeedup(int processors, double parallelFraction) {
    if (parallelFraction < 0 || parallelFraction > 1) {
      throw ArgumentError('Parallel fraction must be between 0 and 1');
    }

    final serialFraction = 1 - parallelFraction;
    return 1 / (serialFraction + (parallelFraction / processors));
  }

  /// Estimate parallel fraction from observed speedup
  ///
  /// Inverse of Amdahl's Law: P = (S*p - p) / (S*p - 1)
  static double? estimateParallelFraction(
    int processors,
    double observedSpeedup,
  ) {
    if (processors <= 1 || observedSpeedup <= 1) return null;

    final numerator = observedSpeedup * processors - processors;
    final denominator = observedSpeedup * processors - 1;

    if (denominator == 0) return null;

    final fraction = numerator / denominator;
    return fraction.clamp(0.0, 1.0);
  }
}
