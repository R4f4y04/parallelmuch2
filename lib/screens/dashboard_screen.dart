import 'package:flutter/material.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';

/// Main dashboard screen displaying all available algorithms.
///
/// Shows the workload grid with algorithm cards and a theory corner.
class DashboardScreen extends StatelessWidget {
  final Function(AlgoConfig) onAlgoSelected;
  final Function(AlgoConfig)? onQuickRun;

  const DashboardScreen({
    super.key,
    required this.onAlgoSelected,
    this.onQuickRun,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Main content area
          Expanded(
            flex: 3,
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Parallel Workloads',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Select an algorithm to explore parallel performance characteristics',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  ),
                ),

                // Algorithm Grid
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 400,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1.2,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final algo = AlgoConfig.allAlgorithms[index];
                      return AlgoCard(
                        algo: algo,
                        onConfigure: () => onAlgoSelected(algo),
                        onQuickRun: onQuickRun != null
                            ? () => onQuickRun!(algo)
                            : null,
                      );
                    }, childCount: AlgoConfig.allAlgorithms.length),
                  ),
                ),
              ],
            ),
          ),

          // Theory Corner Sidebar
          const TheoryCorner(),
        ],
      ),
    );
  }
}

/// Educational sidebar displaying OpenMP tips and architecture concepts.
class TheoryCorner extends StatelessWidget {
  const TheoryCorner({super.key});

  static const List<TheoryTip> _tips = [
    TheoryTip(
      icon: Icons.warning_amber,
      title: 'False Sharing',
      description:
          'Occurs when threads on different processors modify variables that reside on the same cache line, causing unnecessary cache invalidations.',
    ),
    TheoryTip(
      icon: Icons.speed,
      title: "Amdahl's Law",
      description:
          'The theoretical speedup is limited by the serial portion of the code. S = 1 / ((1-P) + P/N) where P is the parallel fraction.',
    ),
    TheoryTip(
      icon: Icons.schedule,
      title: 'Dynamic Scheduling',
      description:
          'Use schedule(dynamic) when workload per iteration varies significantly. Static scheduling divides work upfront.',
    ),
    TheoryTip(
      icon: Icons.sync,
      title: 'Atomic Operations',
      description:
          'Use #pragma omp atomic for thread-safe updates to shared variables. Faster than critical sections for simple operations.',
    ),
    TheoryTip(
      icon: Icons.memory,
      title: 'NUMA Awareness',
      description:
          'On multi-socket systems, threads should access memory close to their physical CPU to minimize latency.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          left: BorderSide(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Theory Corner',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _tips.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) => _TipCard(tip: _tips[index]),
            ),
          ),
        ],
      ),
    );
  }
}

class TheoryTip {
  final IconData icon;
  final String title;
  final String description;

  const TheoryTip({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _TipCard extends StatelessWidget {
  final TheoryTip tip;

  const _TipCard({required this.tip});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                tip.icon,
                size: 20,
                color: Theme.of(context).colorScheme.tertiary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tip.title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            tip.description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[400],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
