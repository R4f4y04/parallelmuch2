import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';

/// Card displaying a code annotation with educational details.
///
/// Explains specific aspects of parallelization with color-coding by type.
class AnnotationCard extends StatelessWidget {
  final CodeAnnotation annotation;
  final bool expanded;

  const AnnotationCard({
    super.key,
    required this.annotation,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = annotation.highlightColor ?? annotation.type.defaultColor;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withOpacity(0.5), width: 1.5),
              ),
              child: Icon(annotation.icon, color: color, size: 22),
            ),

            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title with type badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          annotation.title,
                          style: GoogleFonts.jetBrainsMono(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      _buildTypeBadge(context, color),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Description
                  if (expanded)
                    Text(
                      annotation.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[300],
                        height: 1.5,
                      ),
                    ),

                  // Line references
                  if (annotation.serialLineStart != null ||
                      annotation.parallelLineStart != null) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        if (annotation.serialLineStart != null)
                          _buildLineReference(
                            'Serial Line ${annotation.serialLineStart}',
                            const Color(0xFFFFB020),
                          ),
                        if (annotation.parallelLineStart != null)
                          _buildLineReference(
                            'Parallel Line ${annotation.parallelLineStart}',
                            Theme.of(context).colorScheme.primary,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeBadge(BuildContext context, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        annotation.type.name.toUpperCase(),
        style: GoogleFonts.jetBrainsMono(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildLineReference(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.arrow_forward, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
