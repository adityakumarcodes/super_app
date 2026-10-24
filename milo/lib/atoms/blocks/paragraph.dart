import 'package:flutter/material.dart';

/// Editor.js `paragraph` block.
class ParagraphWidget extends StatelessWidget {
  final String text;

  const ParagraphWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SelectableText(
        text,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.7),
      ),
    );
  }
}
