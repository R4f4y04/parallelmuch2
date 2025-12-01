import 'package:flutter/material.dart';

/// Code snippet model containing serial and parallel implementations.
///
/// Represents an algorithm's code in both sequential and parallel forms
/// with educational annotations explaining the differences.
class CodeSnippet {
  final String algoId;
  final String serialCode;
  final String parallelCode;
  final List<CodeAnnotation> annotations;
  final String serialComplexity;
  final String parallelSpeedupPotential;
  final Map<int, String> serialLineComments;
  final Map<int, String> parallelLineComments;

  const CodeSnippet({
    required this.algoId,
    required this.serialCode,
    required this.parallelCode,
    required this.annotations,
    required this.serialComplexity,
    required this.parallelSpeedupPotential,
    this.serialLineComments = const {},
    this.parallelLineComments = const {},
  });
}

/// Annotation explaining a specific aspect of parallelization.
///
/// Points to specific lines in serial/parallel code and provides
/// educational context about the transformation.
class CodeAnnotation {
  final String title;
  final String description;
  final int? serialLineStart;
  final int? parallelLineStart;
  final AnnotationType type;
  final IconData icon;
  final Color? highlightColor;

  const CodeAnnotation({
    required this.title,
    required this.description,
    this.serialLineStart,
    this.parallelLineStart,
    required this.type,
    required this.icon,
    this.highlightColor,
  });
}

/// Type of code annotation for categorization.
enum AnnotationType {
  optimization,
  warning,
  concept,
  difference,
  performance;

  IconData get defaultIcon {
    switch (this) {
      case AnnotationType.optimization:
        return Icons.speed;
      case AnnotationType.warning:
        return Icons.warning_amber;
      case AnnotationType.concept:
        return Icons.lightbulb;
      case AnnotationType.difference:
        return Icons.compare;
      case AnnotationType.performance:
        return Icons.trending_up;
    }
  }

  Color get defaultColor {
    switch (this) {
      case AnnotationType.optimization:
        return const Color(0xFF00D4AA); // Teal
      case AnnotationType.warning:
        return const Color(0xFFFFB020); // Amber
      case AnnotationType.concept:
        return const Color(0xFF6366F1); // Indigo
      case AnnotationType.difference:
        return const Color(0xFF8B5CF6); // Purple
      case AnnotationType.performance:
        return const Color(0xFF10B981); // Green
    }
  }
}

/// Side of the code viewer (serial or parallel).
enum CodeSide {
  serial,
  parallel;

  String get label {
    switch (this) {
      case CodeSide.serial:
        return 'Sequential';
      case CodeSide.parallel:
        return 'Parallel';
    }
  }
}
