import 'package:flutter/material.dart';
import '../models/models.dart';

/// Badge displaying detected hardware information.
///
/// Shows in the top bar to ground users in their system's capabilities.
class HardwareInfoBadge extends StatelessWidget {
  final HardwareInfo hardwareInfo;
  final bool compact;

  const HardwareInfoBadge({
    super.key,
    required this.hardwareInfo,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.memory,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                compact
                    ? hardwareInfo.compactString
                    : hardwareInfo.displayString,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
              ),
              if (!compact)
                Text(
                  'Max Theoretical Speedup: ${hardwareInfo.theoreticalMaxSpeedup}x',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[400],
                    fontSize: 10,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
