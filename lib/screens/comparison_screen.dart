import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

/// Screen for comparing sequential vs parallel performance.
///
/// Features:
/// - Load multiple benchmark result sets
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
  ComparisonSet? _selectedSet;

  @override
  void initState() {
    super.initState();
    _loadSampleData(); // For demonstration
  }

  void _loadSampleData() {
    // Create sample data for demonstration
    // In a real app, this would load from actual benchmark runs
    final now = DateTime.now();
    final sampleResults = [
      BenchmarkResult(
        algoId: 'matrix_mult',
        threads: 1,
        problemSize: 1024,
        timeSeconds: 8.0,
        timestamp: now,
      ),
      BenchmarkResult(
        algoId: 'matrix_mult',
        threads: 2,
        problemSize: 1024,
        timeSeconds: 4.2,
        timestamp: now,
      ),
      BenchmarkResult(
        algoId: 'matrix_mult',
        threads: 4,
        problemSize: 1024,
        timeSeconds: 2.3,
        timestamp: now,
      ),
      BenchmarkResult(
        algoId: 'matrix_mult',
        threads: 8,
        problemSize: 1024,
        timeSeconds: 1.4,
        timestamp: now,
      ),
      BenchmarkResult(
        algoId: 'matrix_mult',
        threads: 16,
        problemSize: 1024,
        timeSeconds: 1.1,
        timestamp: now,
      ),
    ];

    setState(() {
      final set = _service.addComparison('Matrix Multiplication', sampleResults);
      _selectedSet = set;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _service.allSets.isEmpty
          ? _buildEmptyState()
          : _buildComparisonView(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showLoadDialog,
        icon: const Icon(Icons.add),
        label: const Text('Load Results'),
        tooltip: 'Load benchmark results for comparison',
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.compare_arrows,
            size: 80,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 24),
          Text(
            'No Comparison Data',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(
            'Load benchmark results to start analyzing performance',
            style: TextStyle(color: Colors.grey[400]),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _showLoadDialog,
            icon: const Icon(Icons.upload_file),
            label: const Text('Load Results'),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonView() {
    if (_selectedSet == null) return _buildEmptyState();

    return Row(
      children: [
        // Left sidebar - Comparison list
        Container(
          width: 280,
          decoration: BoxDecoration(
            color: const Color(0xFF0D1117),
            border: Border(
              right: BorderSide(
                color: Colors.grey[800]!,
                width: 1,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.folder_open,
                      color: Theme.of(context).colorScheme.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Comparisons',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _service.allSets.length,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemBuilder: (context, index) {
                    final set = _service.allSets[index];
                    final isSelected = _selectedSet?.id == set.id;

                    return Card(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                          : null,
                      child: ListTile(
                        leading: Icon(
                          Icons.assessment,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey,
                        ),
                        title: Text(
                          set.algoName,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 13,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          _formatTimestamp(set.timestamp),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, size: 18),
                          onPressed: () => _deleteComparison(set.id),
                          tooltip: 'Delete',
                        ),
                        onTap: () => setState(() => _selectedSet = set),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // Main content area
        Expanded(
          child: CustomScrollView(
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
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Performance Comparison Analysis',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
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
                        child: MetricsCard(
                          metrics: _selectedSet!.metrics,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} '
        '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}';
  }

  void _deleteComparison(String id) {
    setState(() {
      _service.removeComparison(id);
      if (_selectedSet?.id == id) {
        _selectedSet = _service.allSets.isNotEmpty ? _service.allSets.first : null;
      }
    });
  }

  void _showLoadDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Load Benchmark Results'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'To load comparison data, run a benchmark from the Execution Screen. '
                'Results will automatically be added here for analysis.',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 16),
              Text(
                'Steps:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('1. Select an algorithm from Dashboard'),
              Text('2. Navigate to Execution Screen'),
              Text('3. Run benchmark with multiple thread counts'),
              Text('4. Return here to view comparison'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // In a real implementation, navigate to dashboard
            },
            child: const Text('Go to Dashboard'),
          ),
        ],
      ),
    );
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
