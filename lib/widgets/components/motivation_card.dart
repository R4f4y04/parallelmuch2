import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Card explaining project motivation and goals.
class MotivationCard extends StatelessWidget {
  const MotivationCard({super.key});

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
                Icon(
                  Icons.lightbulb_outline,
                  color: Colors.amber[600],
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Project Motivation',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Content
            _buildMotivationPoint(
              context,
              icon: Icons.school,
              title: 'Educational Purpose',
              description:
                  'Designed to help students understand parallel computing concepts through hands-on experimentation with real-world algorithms.',
            ),
            const SizedBox(height: 20),

            _buildMotivationPoint(
              context,
              icon: Icons.speed,
              title: 'Performance Visualization',
              description:
                  'Visualize the impact of parallelization on algorithm performance, demonstrating speedup, efficiency, and Amdahl\'s Law in action.',
            ),
            const SizedBox(height: 20),

            _buildMotivationPoint(
              context,
              icon: Icons.architecture,
              title: 'Architectural Concepts',
              description:
                  'Explore key computer architecture topics: cache coherence, memory bandwidth, load balancing, false sharing, and thread synchronization.',
            ),
            const SizedBox(height: 20),

            _buildMotivationPoint(
              context,
              icon: Icons.code,
              title: 'Bridge Theory & Practice',
              description:
                  'Connect high-level UI/UX (Flutter) with low-level system programming (C + OpenMP) to demonstrate full-stack systems thinking.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMotivationPoint(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[300],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[400],
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
