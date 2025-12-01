import 'dart:convert';
import 'dart:io';
import '../models/models.dart';

/// Service for executing C backend processes and managing their lifecycle.
///
/// This is the bridge between the Flutter UI and compiled OpenMP executables.
class ProcessRunnerService {
  final String backendPath;

  ProcessRunnerService({String? backendPath})
    : backendPath = backendPath ?? _defaultBackendPath();

  /// Default path to backend executables (relative to project root)
  static String _defaultBackendPath() {
    // When running in development, executables are in backend/bin/
    final projectRoot = Directory.current.path;
    return '$projectRoot${Platform.pathSeparator}backend${Platform.pathSeparator}bin';
  }

  /// Execute a single benchmark run
  ///
  /// Returns the parsed [BenchmarkResult] or throws an exception on failure.
  Future<BenchmarkResult> runBenchmark({
    required String algoId,
    required int problemSize,
    required int threads,
    void Function(String)? onStdout,
    void Function(String)? onStderr,
  }) async {
    final algo = AlgoConfig.getById(algoId);
    if (algo == null) {
      throw ArgumentError('Unknown algorithm ID: $algoId');
    }

    final executablePath = _getExecutablePath(algo.executableName);

    // Verify executable exists
    if (!await File(executablePath).exists()) {
      throw FileSystemException(
        'Backend executable not found. Please compile the C code first.',
        executablePath,
      );
    }

    // Run process with arguments: <size> <threads>
    final result = await Process.run(executablePath, [
      problemSize.toString(),
      threads.toString(),
    ], runInShell: true);

    // Forward output to callbacks
    if (onStdout != null && result.stdout.toString().isNotEmpty) {
      onStdout(result.stdout.toString());
    }
    if (onStderr != null && result.stderr.toString().isNotEmpty) {
      onStderr(result.stderr.toString());
    }

    // Check for process errors
    if (result.exitCode != 0) {
      throw ProcessException(
        executablePath,
        [problemSize.toString(), threads.toString()],
        'Process exited with code ${result.exitCode}\nStderr: ${result.stderr}',
        result.exitCode,
      );
    }

    // Parse JSON output
    try {
      final jsonOutput = result.stdout.toString().trim();
      final data = jsonDecode(jsonOutput) as Map<String, dynamic>;
      return BenchmarkResult.fromJson(data);
    } catch (e) {
      throw FormatException(
        'Failed to parse JSON output from backend: $e\nOutput: ${result.stdout}',
      );
    }
  }

  /// Execute a full benchmark suite across multiple thread counts
  ///
  /// First runs serial execution (threads=1) as baseline, then parallelizes.
  Future<BenchmarkSuite> runBenchmarkSuite({
    required String algoId,
    required int problemSize,
    required List<int> threadCounts,
    void Function(String)? onStdout,
    void Function(String)? onStderr,
    void Function(int current, int total)? onProgress,
  }) async {
    final results = <BenchmarkResult>[];
    BenchmarkResult? serialBaseline;

    // Always run serial first if not in thread counts
    if (!threadCounts.contains(1)) {
      serialBaseline = await runBenchmark(
        algoId: algoId,
        problemSize: problemSize,
        threads: 1,
        onStdout: onStdout,
        onStderr: onStderr,
      );
      onProgress?.call(0, threadCounts.length);
    }

    // Run each thread count
    for (var i = 0; i < threadCounts.length; i++) {
      final threads = threadCounts[i];
      final result = await runBenchmark(
        algoId: algoId,
        problemSize: problemSize,
        threads: threads,
        onStdout: onStdout,
        onStderr: onStderr,
      );

      // Calculate speedup if this is the serial run
      if (threads == 1) {
        serialBaseline = result;
      } else if (serialBaseline != null) {
        // Add speedup/efficiency relative to baseline
        final speedup = serialBaseline.timeSeconds / result.timeSeconds;
        final efficiency = speedup / threads;
        results.add(result.copyWith(speedup: speedup, efficiency: efficiency));
      } else {
        results.add(result);
      }

      onProgress?.call(i + 1, threadCounts.length);
    }

    return BenchmarkSuite(
      algoId: algoId,
      problemSize: problemSize,
      results: results,
      serialBaseline: serialBaseline,
    );
  }

  /// Get full path to executable
  String _getExecutablePath(String executableName) {
    return '$backendPath${Platform.pathSeparator}$executableName';
  }

  /// Check if backend executables exist
  Future<bool> checkBackendAvailability() async {
    final dir = Directory(backendPath);
    if (!await dir.exists()) return false;

    // Check if at least one executable exists
    final executables = AlgoConfig.allAlgorithms.map(
      (algo) => _getExecutablePath(algo.executableName),
    );

    for (final exe in executables) {
      if (await File(exe).exists()) return true;
    }

    return false;
  }

  /// Get list of available (compiled) algorithms
  Future<List<String>> getAvailableAlgorithms() async {
    final available = <String>[];

    for (final algo in AlgoConfig.allAlgorithms) {
      final exePath = _getExecutablePath(algo.executableName);
      if (await File(exePath).exists()) {
        available.add(algo.id);
      }
    }

    return available;
  }
}
