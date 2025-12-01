import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../services/services.dart';

/// Table displaying comparison data with speedup and efficiency metrics.
class ComparisonTable extends StatelessWidget {
  final ComparisonSet comparisonSet;
  final ComparisonService service;

  const ComparisonTable({
    super.key,
    required this.comparisonSet,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    final baseline = comparisonSet.baseline;
    if (baseline == null) {
      return const Center(child: Text('No baseline data available'));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Comparison',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Table(
              border: TableBorder.all(color: Colors.grey[800]!, width: 1),
              columnWidths: const {
                0: FlexColumnWidth(1.5),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(2),
                3: FlexColumnWidth(2),
              },
              children: [
                // Header
                TableRow(
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                  ),
                  children: [
                    _buildHeaderCell('Threads'),
                    _buildHeaderCell('Time (s)'),
                    _buildHeaderCell('Speedup'),
                    _buildHeaderCell('Efficiency'),
                  ],
                ),
                // Data rows
                ...comparisonSet.sortedResults.map((result) {
                  final speedup = service.calculateSpeedup(baseline, result);
                  final efficiency = service.calculateEfficiency(
                    baseline,
                    result,
                  );
                  final isBaseline = result.threads == baseline.threads;

                  return TableRow(
                    decoration: BoxDecoration(
                      color: isBaseline ? Colors.amber.withOpacity(0.1) : null,
                    ),
                    children: [
                      _buildDataCell(
                        '${result.threads}${isBaseline ? ' (baseline)' : ''}',
                        isBaseline,
                      ),
                      _buildDataCell(
                        result.timeSeconds.toStringAsFixed(4),
                        isBaseline,
                      ),
                      _buildDataCell(
                        speedup.toStringAsFixed(2) + 'x',
                        isBaseline,
                        color: _getSpeedupColor(speedup, result.threads),
                      ),
                      _buildDataCell(
                        '${(efficiency * 100).toStringAsFixed(1)}%',
                        isBaseline,
                        color: _getEfficiencyColor(efficiency),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        text,
        style: GoogleFonts.jetBrainsMono(
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDataCell(String text, bool isBaseline, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        text,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 12,
          color: color ?? (isBaseline ? Colors.amber : Colors.white),
          fontWeight: isBaseline ? FontWeight.bold : FontWeight.normal,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Color _getSpeedupColor(double speedup, int threads) {
    final ideal = threads.toDouble();
    final ratio = speedup / ideal;

    if (ratio >= 0.8) return Colors.green;
    if (ratio >= 0.5) return Colors.orange;
    return Colors.red;
  }

  Color _getEfficiencyColor(double efficiency) {
    if (efficiency >= 0.8) return Colors.green;
    if (efficiency >= 0.5) return Colors.orange;
    return Colors.red;
  }
}
