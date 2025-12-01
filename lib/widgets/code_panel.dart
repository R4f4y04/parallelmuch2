import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import '../models/models.dart';

/// Code display panel with syntax highlighting and line numbers.
///
/// Shows either serial or parallel code with C syntax highlighting.
class CodePanel extends StatelessWidget {
  final String code;
  final CodeSide side;
  final String title;
  final String subtitle;
  final Map<int, String> lineComments;

  const CodePanel({
    super.key,
    required this.code,
    required this.side,
    required this.title,
    required this.subtitle,
    this.lineComments = const {},
  });

  @override
  Widget build(BuildContext context) {
    final lines = code.split('\n');

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: side == CodeSide.serial
              ? const Color(0xFFFFB020).withOpacity(0.3)
              : Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: side == CodeSide.serial
                  ? const Color(0xFFFFB020).withOpacity(0.1)
                  : Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  side == CodeSide.serial ? Icons.looks_one : Icons.apps,
                  color: side == CodeSide.serial
                      ? const Color(0xFFFFB020)
                      : Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: side == CodeSide.serial
                              ? const Color(0xFFFFB020)
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  tooltip: 'Copy Code',
                  onPressed: () => _copyToClipboard(context),
                ),
              ],
            ),
          ),

          // Code with line numbers
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Line numbers
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(
                      lines.length,
                      (index) => Container(
                        height: 20,
                        padding: const EdgeInsets.only(right: 16),
                        child: Text(
                          '${index + 1}',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Code content
                  Expanded(
                    child: HighlightView(
                      code,
                      language: 'c',
                      theme: _getDarkTheme(),
                      padding: EdgeInsets.zero,
                      textStyle: GoogleFonts.jetBrainsMono(
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title copied to clipboard'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Map<String, TextStyle> _getDarkTheme() {
    return {
      'root': const TextStyle(
        color: Color(0xFFE6EDF3),
        backgroundColor: Color(0xFF0D1117),
      ),
      'keyword': const TextStyle(color: Color(0xFFFF7B72)),
      'string': const TextStyle(color: Color(0xFFA5D6FF)),
      'comment': const TextStyle(
        color: Color(0xFF8B949E),
        fontStyle: FontStyle.italic,
      ),
      'number': const TextStyle(color: Color(0xFF79C0FF)),
      'function': const TextStyle(color: Color(0xFFD2A8FF)),
      'type': const TextStyle(color: Color(0xFFFFA657)),
      'operator': const TextStyle(color: Color(0xFF79C0FF)),
      'preprocessor': const TextStyle(color: Color(0xFF8B949E)),
    };
  }
}
