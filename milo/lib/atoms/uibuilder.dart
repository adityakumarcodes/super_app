import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:milo/models/note_image_resolver.dart';
import 'package:milo/services/storage_service.dart';

part 'uibuilder/image_widget.dart';
part 'uibuilder/block_widgets.dart';

class UIBuilder extends StatelessWidget {
  final List<dynamic>? blocks;
  final Map<String, dynamic>? json;

  const UIBuilder({super.key, this.blocks, this.json});

  @override
  Widget build(BuildContext context) {
    final resolvedBlocks = blocks ?? _asList(json?['blocks']);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final block in resolvedBlocks) _buildBlock(context, block),
        ],
      ),
    );
  }

  Widget _buildBlock(BuildContext context, dynamic block) {
    final blockData = _asMap(block);
    final type = blockData['type']?.toString().toLowerCase() ?? '';
    final data = _asMap(blockData['data']);

    switch (type) {
      case 'header':
        return HeadingWidget(
          text: _plainText(data['text']),
          level: data['level'] is num ? (data['level'] as num).toInt() : 1,
        );
      case 'paragraph':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: SelectableText(
            _plainText(data['text']),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.7),
          ),
        );
      case 'delimiter':
        return const DelimiterWidget();
      case 'image':
        final file = _asMap(data['file']);
        final storagePath = extractStoragePath(file);
        final url =
            storagePath ??
            file['url']?.toString() ??
            file['path']?.toString() ??
            '';
        return ImageWidget(imageUrl: url, caption: _plainText(data['caption']));
      case 'list':
        final items = _asList(data['items']);
        if (data['style'] == 'checklist') {
          return ChecklistWidget(items: items);
        }
        return RecursiveListWidget(
          items: items,
          ordered: data['style'] == 'ordered',
        );
      case 'checklist':
        return ChecklistWidget(items: _asList(data['items']));
      case 'callout':
        return CalloutWidget(text: _plainText(data['text']));
      default:
        return _UnsupportedBlock(type: type, data: data);
    }
  }
}

class _UnsupportedBlock extends StatelessWidget {
  final String type;
  final Map<String, dynamic> data;

  const _UnsupportedBlock({required this.type, required this.data});

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

Map<String, dynamic> _asMap(dynamic value) {
  if (value is! Map) return const {};
  return Map<String, dynamic>.from(value);
}

List<dynamic> _asList(dynamic value) => value is List ? value : const [];

String _plainText(dynamic value) {
  if (value == null) return '';

  return value
      .toString()
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'</p\s*>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'<[^>]*>'), '')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&apos;', "'")
      .replaceAll('&amp;', '&')
      .trim();
}
