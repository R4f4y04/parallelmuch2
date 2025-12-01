import 'package:flutter/material.dart';
import '../models/models.dart';

/// A card representing a parallel algorithm workload.
///
/// Displays algorithm name, complexity, architectural tags, and action buttons.
class AlgoCard extends StatelessWidget {
  final AlgoConfig algo;
  final VoidCallback? onQuickRun;
  final VoidCallback? onConfigure;

  const AlgoCard({
    super.key,
    required this.algo,
    this.onQuickRun,
    this.onConfigure,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onConfigure,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon and name
              Row(
                children: [
                  _buildIcon(context),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      algo.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                algo.description,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[400]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),

              // Tags (Complexity + Architectural Concepts)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildComplexityChip(context),
                  ...algo.tags.map((tag) => _buildTagChip(context, tag)),
                ],
              ),
              const Spacer(),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onConfigure != null)
                    TextButton.icon(
                      onPressed: onConfigure,
                      icon: const Icon(Icons.code, size: 18),
                      label: const Text('View Code'),
                    ),
                  const SizedBox(width: 8),
                  if (onQuickRun != null)
                    FilledButton.icon(
                      onPressed: onQuickRun,
                      icon: const Icon(Icons.play_arrow, size: 18),
                      label: const Text('Quick Run'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    IconData iconData;

    switch (algo.iconType) {
      case IconType.matrix:
        iconData = Icons.grid_on;
        break;
      case IconType.sort:
        iconData = Icons.sort;
        break;
      case IconType.random:
        iconData = Icons.scatter_plot;
        break;
      case IconType.physics:
        iconData = Icons.bubble_chart;
        break;
      case IconType.fractal:
        iconData = Icons.auto_awesome;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(iconData, color: color, size: 28),
    );
  }

  Widget _buildComplexityChip(BuildContext context) {
    return Chip(
      label: Text(
        algo.complexity,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      backgroundColor: Theme.of(context).colorScheme.tertiary.withOpacity(0.2),
      side: BorderSide(color: Theme.of(context).colorScheme.tertiary),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildTagChip(BuildContext context, String tag) {
    return Chip(
      label: Text(tag, style: const TextStyle(fontSize: 11)),
      backgroundColor: Theme.of(context).colorScheme.surface,
      side: BorderSide(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
