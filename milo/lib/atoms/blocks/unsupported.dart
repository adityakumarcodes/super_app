import 'dart:convert';

import 'package:flutter/material.dart';

/// Fallback for block types the app does not know; shows the raw JSON.
class UnsupportedBlockWidget extends StatelessWidget {
  final String type;
  final Map<String, dynamic> data;

  const UnsupportedBlockWidget({
    super.key,
    required this.type,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      child: ExpansionTile(
        title: const Text('Unsupported block'),
        subtitle: Text(type.isEmpty ? 'Unknown type' : type),
        childrenPadding: const EdgeInsets.all(12),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Type: ${type.isEmpty ? 'Unknown' : type}'),
          const SizedBox(height: 8),
          const Text('Data', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          SelectableText(const JsonEncoder.withIndent('  ').convert(data)),
        ],
      ),
    );
  }
}
