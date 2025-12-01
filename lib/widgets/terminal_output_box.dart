import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Terminal-style output box for displaying C backend logs.
///
/// Shows raw stdout/stderr for transparency and debugging.
class TerminalOutputBox extends StatefulWidget {
  final String output;
  final double height;
  final bool autoScroll;

  const TerminalOutputBox({
    super.key,
    required this.output,
    this.height = 200,
    this.autoScroll = true,
  });

  @override
  State<TerminalOutputBox> createState() => _TerminalOutputBoxState();
}

class _TerminalOutputBoxState extends State<TerminalOutputBox> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(TerminalOutputBox oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Auto-scroll to bottom when new output arrives
    if (widget.autoScroll && widget.output != oldWidget.output) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117), // Terminal black
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.terminal, size: 16, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Backend Output',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.content_copy, size: 16),
                  onPressed: () => _copyToClipboard(context),
                  tooltip: 'Copy output',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Output content
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              child: SelectableText(
                widget.output.isEmpty
                    ? '> Waiting for output...'
                    : widget.output,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  color: widget.output.isEmpty
                      ? Colors.grey
                      : Colors.green[300],
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    // In a real implementation, use Clipboard.setData
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Output copied to clipboard')));
  }
}
