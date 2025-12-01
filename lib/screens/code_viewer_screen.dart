import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';
import 'execution_screen.dart';

/// Screen showing side-by-side serial vs parallel code comparison.
///
/// Features:
/// - Dual code panels with syntax highlighting
/// - Educational annotations
/// - Quick navigation to execution screen
class CodeViewerScreen extends StatefulWidget {
  final AlgoConfig algoConfig;

  const CodeViewerScreen({super.key, required this.algoConfig});

  @override
  State<CodeViewerScreen> createState() => _CodeViewerScreenState();
}

class _CodeViewerScreenState extends State<CodeViewerScreen> {
  late CodeSnippet? _codeSnippet;
  int? _selectedAnnotationIndex;

  @override
  void initState() {
    super.initState();
    _loadCode();
  }

  void _loadCode() {
    setState(() {
      _codeSnippet = CodeSnippetService.getCodeSnippet(widget.algoConfig.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_codeSnippet == null) {
      return Scaffold(
        appBar: _buildAppBar(context),
        body: const Center(
          child: Text('Code snippet not available for this algorithm.'),
        ),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(context),
      body: Row(
        children: [
          // Left: Code comparison panels
          Expanded(
            flex: 3,
            child: Column(
              children: [
                // Algorithm info header
                _buildAlgorithmHeader(),

                // Serial vs Parallel split view
                Expanded(
                  child: Row(
                    children: [
                      // Serial code
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: CodePanel(
                            code: _codeSnippet!.serialCode,
                            side: CodeSide.serial,
                            title: 'Serial Implementation',
                            subtitle: 'Single-threaded baseline',
                            lineComments: _codeSnippet!.serialLineComments,
                          ),
                        ),
                      ),

                      // Parallel code
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: CodePanel(
                            code: _codeSnippet!.parallelCode,
                            side: CodeSide.parallel,
                            title: 'Parallel Implementation',
                            subtitle: 'OpenMP multi-threaded',
                            lineComments: _codeSnippet!.parallelLineComments,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Right: Annotations panel
          Container(
            width: 400,
            decoration: BoxDecoration(
              color: const Color(0xFF0D1117),
              border: Border(
                left: BorderSide(color: Colors.grey[800]!, width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Annotations header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[800]!, width: 1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: Theme.of(context).colorScheme.primary,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Key Insights',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildComplexityInfo(),
                    ],
                  ),
                ),

                // Annotations list
                Expanded(
                  child: _codeSnippet!.annotations.isEmpty
                      ? Center(
                          child: Text(
                            'No annotations available.',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _codeSnippet!.annotations.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: AnnotationCard(
                                annotation: _codeSnippet!.annotations[index],
                                expanded:
                                    _selectedAnnotationIndex == null ||
                                    _selectedAnnotationIndex == index,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToExecution(context),
        icon: const Icon(Icons.play_arrow),
        label: const Text('Run Benchmark'),
        tooltip: 'Execute this algorithm',
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          Icon(
            _getIconData(widget.algoConfig.iconType),
            size: 24,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.algoConfig.name,
                style: const TextStyle(fontSize: 18),
              ),
              Text(
                'Code Viewer',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[400],
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline),
          tooltip: 'Algorithm Information',
          onPressed: () => _showAlgorithmInfo(context),
        ),
      ],
    );
  }

  Widget _buildAlgorithmHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getIconData(widget.algoConfig.iconType),
            size: 32,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.algoConfig.name,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.algoConfig.description,
                  style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplexityInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            Icons.functions,
            'Complexity',
            _codeSnippet!.serialComplexity,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.trending_up,
            'Speedup Potential',
            _codeSnippet!.parallelSpeedupPotential,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 11,
            color: Colors.grey[500],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void _navigateToExecution(BuildContext context) {
    // Navigate to ExecutionScreen with current algorithm config
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExecutionScreen(algo: widget.algoConfig),
      ),
    );
  }

  void _showAlgorithmInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.algoConfig.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.algoConfig.description,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Text(
                'Complexity: ${_codeSnippet!.serialComplexity}',
                style: GoogleFonts.jetBrainsMono(fontSize: 13),
              ),
              const SizedBox(height: 8),
              Text(
                'Speedup: ${_codeSnippet!.parallelSpeedupPotential}',
                style: GoogleFonts.jetBrainsMono(fontSize: 13),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(IconType iconType) {
    switch (iconType) {
      case IconType.matrix:
        return Icons.grid_on;
      case IconType.sort:
        return Icons.sort;
      case IconType.random:
        return Icons.scatter_plot;
      case IconType.physics:
        return Icons.bubble_chart;
      case IconType.fractal:
        return Icons.auto_awesome;
    }
  }
}
