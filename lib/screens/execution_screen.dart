import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

/// Detailed execution screen for running benchmarks and viewing results.
///
/// Split view with configuration panel, visualization, and terminal output.
class ExecutionScreen extends ConsumerStatefulWidget {
  final AlgoConfig algo;

  const ExecutionScreen({super.key, required this.algo});

  @override
  ConsumerState<ExecutionScreen> createState() => _ExecutionScreenState();
}

class _ExecutionScreenState extends ConsumerState<ExecutionScreen> {
  final ProcessRunnerService _runner = ProcessRunnerService();

  List<BenchmarkResult> _results = [];
  String _terminalOutput = '';
  bool _isRunning = false;
  int _currentIteration = 0;
  int _totalIterations = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.algo.name),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: HardwareInfoBadge(
              hardwareInfo: HardwareInfo.detect(),
              compact: true,
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          // Left Panel - Configuration
          SizedBox(
            width: 400,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ConfigPanel(algo: widget.algo, onExecute: _executeBenchmark),
                  const SizedBox(height: 16),
                  if (_isRunning) _buildProgressIndicator(),
                ],
              ),
            ),
          ),

          // Right Panel - Visualization
          Expanded(
            child: Column(
              children: [
                // Tabs for different views
                Expanded(
                  child: DefaultTabController(
                    length: 3,
                    child: Column(
                      children: [
                        TabBar(
                          tabs: const [
                            Tab(
                              text: 'Speedup',
                              icon: Icon(Icons.show_chart, size: 18),
                            ),
                            Tab(
                              text: 'Efficiency',
                              icon: Icon(Icons.bar_chart, size: 18),
                            ),
                            Tab(
                              text: 'Raw Data',
                              icon: Icon(Icons.table_chart, size: 18),
                            ),
                          ],
                          labelColor: Theme.of(context).colorScheme.primary,
                          indicatorColor: Theme.of(context).colorScheme.primary,
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              // Speedup Chart
                              SpeedupChart(
                                results: _results,
                                showIdealLine: true,
                                showEfficiency: false,
                              ),
                              // Efficiency Chart
                              SpeedupChart(
                                results: _results,
                                showIdealLine: false,
                                showEfficiency: true,
                              ),
                              // Raw Data Table
                              _buildDataTable(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Terminal Output at Bottom
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TerminalOutputBox(
                    output: _terminalOutput,
                    height: 200,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final progress = _totalIterations > 0
        ? _currentIteration / _totalIterations
        : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Running... ($_currentIteration/$_totalIterations)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: progress, minHeight: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable() {
    if (_results.isEmpty) {
      return Center(
        child: Text(
          'No data available\nRun a benchmark to see results',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Threads')),
          DataColumn(label: Text('Time (s)')),
          DataColumn(label: Text('Speedup')),
          DataColumn(label: Text('Efficiency')),
        ],
        rows: _results.map((result) {
          return DataRow(
            cells: [
              DataCell(Text(result.threads.toString())),
              DataCell(Text(result.timeSeconds.toStringAsFixed(4))),
              DataCell(Text(result.speedup?.toStringAsFixed(2) ?? 'N/A')),
              DataCell(Text(result.efficiency?.toStringAsFixed(2) ?? 'N/A')),
            ],
          );
        }).toList(),
      ),
    );
  }

  Future<void> _executeBenchmark(int size, List<int> threadCounts) async {
    setState(() {
      _isRunning = true;
      _results = [];
      _terminalOutput = '> Starting benchmark: ${widget.algo.name}\n';
      _terminalOutput += '> Problem size: $size\n';
      _terminalOutput += '> Thread counts: ${threadCounts.join(", ")}\n\n';
      _currentIteration = 0;
      _totalIterations = threadCounts.length;
    });

    try {
      final suite = await _runner.runBenchmarkSuite(
        algoId: widget.algo.id,
        problemSize: size,
        threadCounts: threadCounts,
        onStdout: (output) {
          setState(() {
            _terminalOutput += output;
          });
        },
        onStderr: (error) {
          setState(() {
            _terminalOutput += '[ERROR] $error\n';
          });
        },
        onProgress: (current, total) {
          setState(() {
            _currentIteration = current;
          });
        },
      );

      setState(() {
        _results = suite.resultsWithSpeedup;
        _terminalOutput += '\n> Benchmark complete!\n';
        _terminalOutput +=
            '> Max speedup: ${suite.maxSpeedup?.toStringAsFixed(2) ?? "N/A"}x\n';
        _terminalOutput +=
            '> Avg efficiency: ${suite.avgEfficiency?.toStringAsFixed(2) ?? "N/A"}\n';
      });
    } catch (e) {
      setState(() {
        _terminalOutput += '\n[ERROR] $e\n';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Benchmark failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }
}
