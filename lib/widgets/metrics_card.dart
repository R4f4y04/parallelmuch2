import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';

/// Card displaying key metrics from comparison analysis.
class MetricsCard extends StatelessWidget {
  final ComparisonMetrics metrics;

  const MetricsCard({
    super.key,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: Theme.of(context).colorScheme.primary,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Text(
                  'Analysis Summary',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildMetricRow(
              context,
              'Maximum Speedup',
              '${metrics.maxSpeedup.toStringAsFixed(2)}x',
              Icons.speed,
              _getSpeedupColor(metrics.maxSpeedup),
            ),
            const SizedBox(height: 12),
            _buildMetricRow(
              context,
              'Average Speedup',
              '${metrics.averageSpeedup.toStringAsFixed(2)}x',
              Icons.trending_up,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildMetricRow(
              context,
              'Average Efficiency',
              '${(metrics.averageEfficiency * 100).toStringAsFixed(1)}%',
              Icons.battery_charging_full,
              _getEfficiencyColor(metrics.averageEfficiency),
            ),
            const SizedBox(height: 12),
            _buildMetricRow(
              context,
              'Optimal Thread Count',
              '${metrics.optimalThreadCount}',
              Icons.settings_suggest,
              Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            _buildMetricRow(
              context,
              'Serial Fraction',
              '${(metrics.serialFraction * 100).toStringAsFixed(1)}%',
              Icons.linear_scale,
              Colors.orange,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.amber.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    color: Colors.amber,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _getRecommendation(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.amber,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 18,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              color: Colors.grey[400],
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getSpeedupColor(double speedup) {
    if (speedup >= 6) return Colors.green;
    if (speedup >= 3) return Colors.blue;
    if (speedup >= 1.5) return Colors.orange;
    return Colors.red;
  }

  Color _getEfficiencyColor(double efficiency) {
    if (efficiency >= 0.8) return Colors.green;
    if (efficiency >= 0.5) return Colors.orange;
    return Colors.red;
  }

  String _getRecommendation() {
    if (metrics.averageEfficiency >= 0.8) {
      return 'Excellent parallelization! Efficiency above 80%.';
    } else if (metrics.averageEfficiency >= 0.5) {
      return 'Good parallelization. Consider reducing thread count for better efficiency.';
    } else if (metrics.serialFraction > 0.3) {
      return 'High serial fraction detected. Review Amdahl\'s Law limitations.';
    } else {
      return 'Low efficiency. Check for synchronization overhead or load imbalance.';
    }
  }
}
