import 'dart:io';
import 'package:flutter/material.dart';
import '../models/models.dart';

/// Enhanced system information detection service.
///
/// Provides detailed hardware specs and parallelism recommendations.
class SystemInfoService {
  /// Get comprehensive system information
  static Future<DetailedSystemInfo> getDetailedInfo() async {
    final basicInfo = HardwareInfo.detect();

    // Get CPU information from environment
    final cpuModel =
        Platform.environment['PROCESSOR_IDENTIFIER'] ??
        Platform.environment['CPU'] ??
        'Unknown CPU';

    // Detect cache line size (typical is 64 bytes)
    const cacheLineSize = 64; // Common for x86/x64

    // Estimate physical cores (logical / 2 for hyperthreading)
    final physicalCores = (basicInfo.logicalCores / 2).round();
    final hasHyperthreading = basicInfo.logicalCores > physicalCores;

    // Memory information
    final totalMemory = _estimateMemory();

    // Parallelism efficiency estimation
    final parallelismGrade = _calculateParallelismGrade(basicInfo);

    return DetailedSystemInfo(
      basicInfo: basicInfo,
      cpuModel: cpuModel,
      physicalCores: physicalCores,
      logicalCores: basicInfo.logicalCores,
      hasHyperthreading: hasHyperthreading,
      cacheLineSize: cacheLineSize,
      totalMemoryMB: totalMemory,
      parallelismGrade: parallelismGrade,
      recommendations: _generateRecommendations(basicInfo, physicalCores),
    );
  }

  /// Estimate system memory (simplified)
  static int _estimateMemory() {
    // This is a simplified estimation
    // In production, you'd use platform-specific APIs or FFI
    return 16384; // Default to 16GB as placeholder
  }

  /// Calculate parallelism efficiency grade
  static ParallelismGrade _calculateParallelismGrade(HardwareInfo info) {
    if (info.logicalCores >= 16) {
      return ParallelismGrade.excellent;
    } else if (info.logicalCores >= 8) {
      return ParallelismGrade.veryGood;
    } else if (info.logicalCores >= 4) {
      return ParallelismGrade.good;
    } else if (info.logicalCores >= 2) {
      return ParallelismGrade.fair;
    } else {
      return ParallelismGrade.poor;
    }
  }

  /// Generate hardware-specific recommendations
  static List<SystemRecommendation> _generateRecommendations(
    HardwareInfo info,
    int physicalCores,
  ) {
    final recommendations = <SystemRecommendation>[];

    // Thread count recommendation
    recommendations.add(
      SystemRecommendation(
        title: 'Optimal Thread Count',
        description:
            'For best performance, use ${physicalCores} threads '
            '(matching physical cores) to avoid hyperthreading overhead.',
        severity: RecommendationSeverity.info,
        icon: Icons.psychology,
      ),
    );

    // Memory bandwidth warning
    if (info.logicalCores >= 8) {
      recommendations.add(
        SystemRecommendation(
          title: 'Memory Bandwidth Aware',
          description:
              'With ${info.logicalCores} threads, memory bandwidth '
              'becomes critical. Matrix Multiplication and Merge Sort will show '
              'diminishing returns beyond ${physicalCores} threads.',
          severity: RecommendationSeverity.warning,
          icon: Icons.memory,
        ),
      );
    }

    // False sharing warning
    recommendations.add(
      SystemRecommendation(
        title: 'False Sharing Risk',
        description:
            'Cache line size is typically 64 bytes. Ensure data '
            'structures used by different threads are padded to avoid '
            'false sharing in Matrix Multiplication.',
        severity: RecommendationSeverity.info,
        icon: Icons.warning_amber,
      ),
    );

    // Amdahl's Law reminder
    final maxTheoretical = info.logicalCores;
    recommendations.add(
      SystemRecommendation(
        title: "Amdahl's Law Limit",
        description:
            'Maximum theoretical speedup is ${maxTheoretical}x with '
            '${info.logicalCores} cores, but only if code is 100% parallel. '
            'Real speedup will be lower due to serial portions.',
        severity: RecommendationSeverity.info,
        icon: Icons.trending_up,
      ),
    );

    // Low core count warning
    if (info.logicalCores <= 2) {
      recommendations.add(
        SystemRecommendation(
          title: 'Limited Parallelism',
          description:
              'With only ${info.logicalCores} cores, speedup will be '
              'minimal. Consider running on a system with more cores for better '
              'demonstration of parallel algorithms.',
          severity: RecommendationSeverity.warning,
          icon: Icons.info,
        ),
      );
    }

    // High core count optimization
    if (info.logicalCores >= 16) {
      recommendations.add(
        SystemRecommendation(
          title: 'NUMA Considerations',
          description:
              'With ${info.logicalCores}+ cores, your system likely has '
              'NUMA architecture. Thread affinity and memory locality become '
              'important for optimal performance.',
          severity: RecommendationSeverity.info,
          icon: Icons.hub,
        ),
      );
    }

    return recommendations;
  }
}

/// Detailed system information model
class DetailedSystemInfo {
  final HardwareInfo basicInfo;
  final String cpuModel;
  final int physicalCores;
  final int logicalCores;
  final bool hasHyperthreading;
  final int cacheLineSize;
  final int totalMemoryMB;
  final ParallelismGrade parallelismGrade;
  final List<SystemRecommendation> recommendations;

  const DetailedSystemInfo({
    required this.basicInfo,
    required this.cpuModel,
    required this.physicalCores,
    required this.logicalCores,
    required this.hasHyperthreading,
    required this.cacheLineSize,
    required this.totalMemoryMB,
    required this.parallelismGrade,
    required this.recommendations,
  });

  /// Get parallelism efficiency percentage
  double get parallelismEfficiency {
    return (physicalCores / 16 * 100).clamp(0, 100);
  }

  /// Get memory in GB
  double get totalMemoryGB => totalMemoryMB / 1024.0;
}

/// Parallelism capability grade
enum ParallelismGrade {
  excellent,
  veryGood,
  good,
  fair,
  poor;

  String get label {
    switch (this) {
      case ParallelismGrade.excellent:
        return 'Excellent';
      case ParallelismGrade.veryGood:
        return 'Very Good';
      case ParallelismGrade.good:
        return 'Good';
      case ParallelismGrade.fair:
        return 'Fair';
      case ParallelismGrade.poor:
        return 'Poor';
    }
  }

  Color get color {
    switch (this) {
      case ParallelismGrade.excellent:
        return const Color(0xFF00FF00); // Bright green
      case ParallelismGrade.veryGood:
        return const Color(0xFF00D4AA); // Teal
      case ParallelismGrade.good:
        return const Color(0xFFFFB020); // Amber
      case ParallelismGrade.fair:
        return const Color(0xFFFF8800); // Orange
      case ParallelismGrade.poor:
        return const Color(0xFFFF4444); // Red
    }
  }
}

/// System recommendation model
class SystemRecommendation {
  final String title;
  final String description;
  final RecommendationSeverity severity;
  final IconData icon;

  const SystemRecommendation({
    required this.title,
    required this.description,
    required this.severity,
    required this.icon,
  });
}

/// Recommendation severity levels
enum RecommendationSeverity {
  info,
  warning,
  critical;

  Color get color {
    switch (this) {
      case RecommendationSeverity.info:
        return const Color(0xFF00D4AA); // Teal
      case RecommendationSeverity.warning:
        return const Color(0xFFFFB020); // Amber
      case RecommendationSeverity.critical:
        return const Color(0xFFFF4444); // Red
    }
  }
}
