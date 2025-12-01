import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';

/// Chart displaying speedup curves for parallel execution.
///
/// Shows observed speedup vs thread count with ideal linear speedup reference.
class SpeedupChart extends StatelessWidget {
  final List<BenchmarkResult> results;
  final bool showIdealLine;
  final bool showEfficiency;

  const SpeedupChart({
    super.key,
    required this.results,
    this.showIdealLine = true,
    this.showEfficiency = false,
  });

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return Center(
        child: Text(
          'No data to display',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
        ),
      );
    }

    final sortedResults = [...results]
      ..sort((a, b) => a.threads.compareTo(b.threads));
    final threadCounts = sortedResults.map((r) => r.threads).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1),
            getDrawingVerticalLine: (value) =>
                FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              axisNameWidget: Text(
                showEfficiency ? 'Efficiency' : 'Speedup',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) => Text(
                  value.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              axisNameWidget: Text(
                'Thread Count',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
          ),
          lineBarsData: [
            // Observed speedup line
            _buildObservedLine(context, sortedResults),

            // Ideal linear speedup line (reference)
            if (showIdealLine && !showEfficiency)
              _buildIdealLine(context, threadCounts),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final result = sortedResults[spot.spotIndex];
                  final value = showEfficiency
                      ? result.efficiency
                      : result.speedup;
                  return LineTooltipItem(
                    '${result.threads} threads\n${value?.toStringAsFixed(2) ?? "N/A"}x',
                    const TextStyle(color: Colors.white, fontSize: 12),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  LineChartBarData _buildObservedLine(
    BuildContext context,
    List<BenchmarkResult> sorted,
  ) {
    final spots = sorted
        .where((r) => showEfficiency ? r.efficiency != null : r.speedup != null)
        .map(
          (r) => FlSpot(
            r.threads.toDouble(),
            showEfficiency ? r.efficiency! : r.speedup!,
          ),
        )
        .toList();

    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: Theme.of(context).colorScheme.primary,
      barWidth: 3,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
          radius: 4,
          color: Theme.of(context).colorScheme.primary,
          strokeWidth: 2,
          strokeColor: Colors.white,
        ),
      ),
      belowBarData: BarAreaData(
        show: true,
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      ),
    );
  }

  LineChartBarData _buildIdealLine(BuildContext context, List<int> threads) {
    final idealSpeedup = DataParsingService.calculateIdealSpeedup(threads);
    final spots = List.generate(
      threads.length,
      (i) => FlSpot(threads[i].toDouble(), idealSpeedup[i]),
    );

    return LineChartBarData(
      spots: spots,
      isCurved: false,
      color: Theme.of(context).colorScheme.tertiary.withOpacity(0.5),
      barWidth: 2,
      dashArray: [5, 5], // Dashed line
      dotData: const FlDotData(show: false),
    );
  }
}
