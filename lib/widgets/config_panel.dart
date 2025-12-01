import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';

/// Configuration panel for setting up benchmark parameters.
///
/// Allows users to adjust problem size and thread range before execution.
class ConfigPanel extends StatefulWidget {
  final AlgoConfig algo;
  final Function(int size, List<int> threads) onExecute;

  const ConfigPanel({super.key, required this.algo, required this.onExecute});

  @override
  State<ConfigPanel> createState() => _ConfigPanelState();
}

class _ConfigPanelState extends State<ConfigPanel> {
  late int _problemSize;
  late int _minThreads;
  late int _maxThreads;

  @override
  void initState() {
    super.initState();
    _problemSize = widget.algo.defaultSize;
    _minThreads = 1;
    _maxThreads = 16; // Will be capped by hardware
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Benchmark Configuration',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),

            // Problem Size
            _buildSizeControl(),
            const SizedBox(height: 20),

            // Thread Range
            _buildThreadRangeControl(),
            const SizedBox(height: 24),

            // Execute Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: _executePressed,
                icon: const Icon(Icons.play_arrow),
                label: const Text(
                  'EXECUTE BENCHMARK',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSizeControl() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Problem Size (N)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 120,
              child: TextField(
                controller: TextEditingController(
                  text: _problemSize.toString(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  final parsed = int.tryParse(value);
                  if (parsed != null) {
                    setState(() => _problemSize = parsed);
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Slider(
          value: _problemSize.toDouble(),
          min: widget.algo.minSize.toDouble(),
          max: widget.algo.maxSize.toDouble(),
          divisions:
              ((widget.algo.maxSize - widget.algo.minSize) /
                      widget.algo.sizeStep)
                  .round(),
          label: _problemSize.toString(),
          onChanged: (value) => setState(() => _problemSize = value.toInt()),
        ),
        Text(
          'Range: ${widget.algo.minSize} - ${widget.algo.maxSize}',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildThreadRangeControl() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Thread Range', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Min', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 4),
                  TextField(
                    controller: TextEditingController(
                      text: _minThreads.toString(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      final parsed = int.tryParse(value);
                      if (parsed != null && parsed >= 1) {
                        setState(() => _minThreads = parsed);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Max', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 4),
                  TextField(
                    controller: TextEditingController(
                      text: _maxThreads.toString(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      final parsed = int.tryParse(value);
                      if (parsed != null && parsed >= _minThreads) {
                        setState(() => _maxThreads = parsed);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Will test: ${_getThreadCounts().join(", ")}',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  List<int> _getThreadCounts() {
    final counts = <int>[];
    for (int t = _minThreads; t <= _maxThreads; t *= 2) {
      counts.add(t);
    }
    if (counts.last != _maxThreads && _maxThreads > counts.last) {
      counts.add(_maxThreads);
    }
    return counts;
  }

  void _executePressed() {
    final threadCounts = _getThreadCounts();
    widget.onExecute(_problemSize, threadCounts);
  }
}
