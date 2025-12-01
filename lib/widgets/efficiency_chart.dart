import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../services/services.dart';

/// Chart displaying efficiency comparison with Amdahl's Law overlay.
class EfficiencyChart extends StatelessWidget {
  final ComparisonSet comparisonSet;
  final ComparisonService service;
  final bool showAmdahl;

  const EfficiencyChart({
    super.key,
    required this.comparisonSet,
    required this.service,
    this.showAmdahl = true,
  });

  @override
  Widget build(BuildContext context) {
    final baseline = comparisonSet.baseline;
    if (baseline == null) {
      return const Center(child: Text('No data available'));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Speedup Analysis',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                _buildLegend(context),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: LineChart(_buildChartData(context, baseline)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      children: [
        _buildLegendItem(
          context,
          'Actual',
          Theme.of(context).colorScheme.primary,
          solid: true,
        ),
        const SizedBox(width: 16),
        _buildLegendItem(
          context,
          'Ideal (Linear)',
          Colors.grey,
          solid: false,
        ),
        if (showAmdahl) ...[
          const SizedBox(width: 16),
          _buildLegendItem(
            context,
            'Amdahl\'s Law',
            Colors.orange,
            solid: false,
          ),
        ],
      ],
    );
  }

  Widget _buildLegendItem(
    BuildContext context,
    String label,
    Color color, {
    required bool solid,
  }) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 3,
          decoration: BoxDecoration(
            color: solid ? color : null,
            border: solid ? null : Border.all(color: color, width: 2),
          ),
          child: solid
              ? null
              : CustomPaint(
                  painter: DashedLinePainter(color: color),
                ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.jetBrainsMono(fontSize: 11),
        ),
      ],
    );
  }

  LineChartData _buildChartData(BuildContext context, BenchmarkResult baseline) {
    final actualSpots = <FlSpot>[];
    final idealSpots = <FlSpot>[];
    final amdahlSpots = <FlSpot>[];

    double maxThreads = 1;
    double maxSpeedup = 1;

    for (final result in comparisonSet.sortedResults) {
      final speedup = service.calculateSpeedup(baseline, result);
      actualSpots.add(FlSpot(result.threads.toDouble(), speedup));
      
      if (result.threads > maxThreads) maxThreads = result.threads.toDouble();
      if (speedup > maxSpeedup) maxSpeedup = speedup;
    }

    // Generate ideal linear speedup
    for (int t = 1; t <= maxThreads; t++) {
      idealSpots.add(FlSpot(t.toDouble(), t.toDouble()));
    }

    // Generate Amdahl's Law curve
    if (showAmdahl) {
      final amdahlCurve = service.generateAmdahlCurve(
        comparisonSet.metrics,
        maxThreads.toInt(),
      );
      for (final point in amdahlCurve) {
        amdahlSpots.add(FlSpot(point.key.toDouble(), point.value));
      }
    }

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) => FlLine(
          color: Colors.grey[800]!,
          strokeWidth: 1,
        ),
        getDrawingVerticalLine: (value) => FlLine(
          color: Colors.grey[800]!,
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          axisNameWidget: Text(
            'Speedup',
            style: GoogleFonts.jetBrainsMono(fontSize: 12),
          ),
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) => Text(
              '${value.toInt()}x',
              style: GoogleFonts.jetBrainsMono(fontSize: 10),
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
            style: GoogleFonts.jetBrainsMono(fontSize: 12),
          ),
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) => Text(
              value.toInt().toString(),
              style: GoogleFonts.jetBrainsMono(fontSize: 10),
            ),
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.grey[800]!),
      ),
      minX: 1,
      maxX: maxThreads,
      minY: 0,
      maxY: (maxSpeedup * 1.2).ceilToDouble(),
      lineBarsData: [
        // Actual speedup
        LineChartBarData(
          spots: actualSpots,
          isCurved: true,
          color: Theme.of(context).colorScheme.primary,
          barWidth: 3,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          ),
        ),
        // Ideal linear speedup
        LineChartBarData(
          spots: idealSpots,
          isCurved: false,
          color: Colors.grey,
          barWidth: 2,
          dotData: const FlDotData(show: false),
          dashArray: [5, 5],
        ),
        // Amdahl's Law
        if (showAmdahl)
          LineChartBarData(
            spots: amdahlSpots,
            isCurved: true,
            color: Colors.orange,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            dashArray: [3, 3],
          ),
      ],
    );
  }
}

/// Custom painter for dashed lines in legend.
class DashedLinePainter extends CustomPainter {
  final Color color;

  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2;

    const dashWidth = 3;
    const dashSpace = 3;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
