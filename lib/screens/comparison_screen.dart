import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

/// Screen for comparing sequential vs parallel performance.
///
/// Features:
/// - Run benchmarks directly with custom parameters
/// - Visualize speedup and efficiency
/// - Show Amdahl's Law overlay
/// - Export comparison data
class ComparisonScreen extends StatefulWidget {
  const ComparisonScreen({super.key});

  @override
  State<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen> {
  final ComparisonService _service = ComparisonService();
  final ProcessRunnerService _runner = ProcessRunnerService();

  ComparisonSet? _selectedSet;
  AlgoConfig? _selectedAlgo;

  // Configuration parameters
  int _problemSize = 1024;
  int _minThreads = 1;
  int _maxThreads = 8;

  // Execution state
  bool _isRunning = false;
  int _currentIteration = 0;
  int _totalIterations = 0;
  String _terminalOutput = '';

  @override
  void initState() {
    super.initState();
    // No sample data - user must run benchmarks
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left panel - Configuration
          _buildConfigPanel(),

          // Right panel - Results or empty state
          Expanded(
            child: _selectedSet == null
                ? _buildEmptyState()
                : _buildComparisonView(),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigPanel() {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        border: Border(right: BorderSide(color: Colors.grey[800]!, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Icon(
                  Icons.settings,
                  color: Theme.of(context).colorScheme.primary,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Text(
                  'Benchmark Setup',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Algorithm selection
                  _buildSectionTitle('1. Select Algorithm'),
                  const SizedBox(height: 12),
                  _buildAlgorithmDropdown(),

                  const SizedBox(height: 24),

                  // Problem size
                  if (_selectedAlgo != null) ...[
                    _buildSectionTitle('2. Problem Size'),
                    const SizedBox(height: 12),
                    _buildProblemSizeControl(),

                    const SizedBox(height: 24),

                    // Thread range
                    _buildSectionTitle('3. Thread Range'),
                    const SizedBox(height: 12),
                    _buildThreadRangeControl(),

                    const SizedBox(height: 32),

                    // Execute button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton.icon(
                        onPressed: _isRunning ? null : _executeBenchmark,
                        icon: _isRunning
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.play_arrow),
                        label: Text(
                          _isRunning ? 'Running...' : 'Run Benchmark',
                        ),
                      ),
                    ),

                    if (_isRunning) ...[
                      const SizedBox(height: 16),
                      _buildProgressIndicator(),
                    ],

                    const SizedBox(height: 24),

                    // Terminal output
                    if (_terminalOutput.isNotEmpty) ...[
                      _buildSectionTitle('Terminal Output'),
                      const SizedBox(height: 12),
                      Container(
                        height: 200,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[800]!),
                        ),
                        child: SingleChildScrollView(
                          child: Text(
                            _terminalOutput,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 11,
                              color: Colors.green[400],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.compare_arrows, size: 80, color: Colors.grey[600]),
          const SizedBox(height: 24),
          Text(
            'No Comparison Data',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(
            'Select an algorithm and run a benchmark',
            style: TextStyle(color: Colors.grey[400]),
          ),
          const SizedBox(height: 8),
          Text(
            'to start analyzing performance',
            style: TextStyle(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonView() {
    if (_selectedSet == null) return _buildEmptyState();

    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedSet!.algoName,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Performance Comparison Analysis',
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                IconButton.outlined(
                  onPressed: _exportCSV,
                  icon: const Icon(Icons.download),
                  tooltip: 'Export as CSV',
                ),
                const SizedBox(width: 8),
                IconButton.outlined(
                  onPressed: _exportJSON,
                  icon: const Icon(Icons.code),
                  tooltip: 'Export as JSON',
                ),
              ],
            ),
          ),
        ),

        // Content grid
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          sliver: SliverToBoxAdapter(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column - Chart and Table
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      EfficiencyChart(
                        comparisonSet: _selectedSet!,
                        service: _service,
                      ),
                      const SizedBox(height: 16),
                      ComparisonTable(
                        comparisonSet: _selectedSet!,
                        service: _service,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // Right column - Metrics
                Expanded(
                  flex: 1,
                  child: MetricsCard(metrics: _selectedSet!.metrics),
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.jetBrainsMono(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Colors.grey[400],
      ),
    );
  }

  Widget _buildAlgorithmDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: DropdownButton<AlgoConfig>(
        isExpanded: true,
        value: _selectedAlgo,
        hint: const Text('Choose algorithm...'),
        underline: const SizedBox(),
        dropdownColor: const Color(0xFF161B22),
        items: AlgoConfig.allAlgorithms.map((algo) {
          return DropdownMenuItem(
            value: algo,
            child: Text(
              algo.name,
              style: GoogleFonts.jetBrainsMono(fontSize: 12),
            ),
          );
        }).toList(),
        onChanged: (algo) {
          setState(() {
            _selectedAlgo = algo;
            if (algo != null) {
              _problemSize = algo.defaultSize;
            }
          });
        },
      ),
    );
  }

  Widget _buildProblemSizeControl() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Size: $_problemSize',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12,
                color: Colors.white,
              ),
            ),
            Text(
              '${_selectedAlgo!.minSize} - ${_selectedAlgo!.maxSize}',
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: _problemSize.toDouble(),
          min: _selectedAlgo!.minSize.toDouble(),
          max: _selectedAlgo!.maxSize.toDouble(),
          divisions:
              (_selectedAlgo!.maxSize - _selectedAlgo!.minSize) ~/
              _selectedAlgo!.sizeStep,
          onChanged: (value) {
            setState(() => _problemSize = value.round());
          },
        ),
      ],
    );
  }

  Widget _buildThreadRangeControl() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Min Threads: $_minThreads',
          style: GoogleFonts.jetBrainsMono(fontSize: 12, color: Colors.white),
        ),
        Slider(
          value: _minThreads.toDouble(),
          min: 1,
          max: 16,
          divisions: 15,
          onChanged: (value) {
            setState(() {
              _minThreads = value.round();
              if (_minThreads > _maxThreads) {
                _maxThreads = _minThreads;
              }
            });
          },
        ),
        const SizedBox(height: 16),
        Text(
          'Max Threads: $_maxThreads',
          style: GoogleFonts.jetBrainsMono(fontSize: 12, color: Colors.white),
        ),
        Slider(
          value: _maxThreads.toDouble(),
          min: 1,
          max: 16,
          divisions: 15,
          onChanged: (value) {
            setState(() {
              _maxThreads = value.round();
              if (_maxThreads < _minThreads) {
                _minThreads = _maxThreads;
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    if (_totalIterations == 0) return const SizedBox();

    final progress = _currentIteration / _totalIterations;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                color: Colors.grey[400],
              ),
            ),
            Text(
              '$_currentIteration / $_totalIterations',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[800],
        ),
      ],
    );
  }

  Future<void> _executeBenchmark() async {
    if (_selectedAlgo == null || _isRunning) return;

    setState(() {
      _isRunning = true;
      _terminalOutput = '';
      _currentIteration = 0;
    });

    try {
      // Generate thread counts
      final threadCounts = <int>[];
      for (int t = _minThreads; t <= _maxThreads; t *= 2) {
        threadCounts.add(t);
      }
      if (!threadCounts.contains(_maxThreads)) {
        threadCounts.add(_maxThreads);
      }

      setState(() => _totalIterations = threadCounts.length);

      final results = <BenchmarkResult>[];

      // Run benchmarks for each thread count
      for (final threads in threadCounts) {
        setState(() {
          _currentIteration++;
          _terminalOutput += '\nRunning with $threads threads...\n';
        });

        final result = await _runner.runBenchmark(
          algoId: _selectedAlgo!.id,
          problemSize: _problemSize,
          threads: threads,
          onStdout: (output) {
            setState(() => _terminalOutput += output);
          },
          onStderr: (error) {
            setState(() => _terminalOutput += '[ERROR] $error\n');
          },
        );

        results.add(result);

        setState(() {
          _terminalOutput +=
              '✓ Completed: ${result.timeSeconds.toStringAsFixed(3)}s\n';
        });
      }

      // Create comparison set
      final set = _service.addComparison(_selectedAlgo!.name, results);

      setState(() {
        _selectedSet = set;
        _terminalOutput += '\n✓ Benchmark complete! Analysis ready.\n';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Benchmark completed successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _terminalOutput += '\n✗ Error: $e\n';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Benchmark failed: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() => _isRunning = false);
    }
  }

  void _exportCSV() {
    if (_selectedSet == null) return;

    final csv = _service.exportAsCSV(_selectedSet!);
    Clipboard.setData(ClipboardData(text: csv));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('CSV data copied to clipboard'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _exportJSON() {
    final json = _service.exportAllAsJSON();
    Clipboard.setData(ClipboardData(text: json));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('JSON data copied to clipboard'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
