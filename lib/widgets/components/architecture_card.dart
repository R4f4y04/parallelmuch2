import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Card explaining the system architecture and how components communicate.
class ArchitectureCard extends StatelessWidget {
  const ArchitectureCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.hub, color: Colors.teal[400], size: 28),
                const SizedBox(width: 12),
                Text(
                  'How It Works',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Architecture Diagram
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1117),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[800]!),
              ),
              child: Column(
                children: [
                  _buildArchitectureLayer(
                    context,
                    title: '1. Flutter Frontend (Desktop)',
                    description:
                        'Dart/Flutter UI manages user interaction, visualizations, and displays results',
                    color: Colors.blue,
                    icon: Icons.desktop_windows,
                  ),
                  const SizedBox(height: 16),
                  _buildArrow(context),
                  const SizedBox(height: 16),
                  _buildArchitectureLayer(
                    context,
                    title: '2. Process Communication',
                    description:
                        'Flutter spawns C executables via dart:io Process.run() with CLI arguments',
                    color: Colors.purple,
                    icon: Icons.swap_vert,
                  ),
                  const SizedBox(height: 16),
                  _buildArrow(context),
                  const SizedBox(height: 16),
                  _buildArchitectureLayer(
                    context,
                    title: '3. C Backend (OpenMP)',
                    description:
                        'Compiled .exe files execute parallel algorithms and output JSON results',
                    color: Colors.green,
                    icon: Icons.settings_applications,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Key Points
            _buildKeyPoint(
              context,
              'No Computation in Dart',
              'Flutter is purely a GUI. All heavy math happens in native C code.',
            ),
            const SizedBox(height: 12),
            _buildKeyPoint(
              context,
              'Decoupled Architecture',
              'Frontend and backend are separate. C executables can be tested independently.',
            ),
            const SizedBox(height: 12),
            _buildKeyPoint(
              context,
              'JSON Communication',
              'C programs output JSON to stdout, parsed by Flutter\'s DataParsingService.',
            ),
            const SizedBox(height: 12),
            _buildKeyPoint(
              context,
              'OpenMP Parallelism',
              'Backend uses #pragma omp directives for multi-threaded execution.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArchitectureLayer(
    BuildContext context, {
    required String title,
    required String description,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArrow(BuildContext context) {
    return Icon(Icons.arrow_downward, color: Colors.grey[600], size: 24);
  }

  Widget _buildKeyPoint(
    BuildContext context,
    String title,
    String description,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle, color: Colors.green[400], size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 14, color: Colors.grey[300]),
              children: [
                TextSpan(
                  text: '$title: ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: description,
                  style: TextStyle(color: Colors.grey[400]),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
