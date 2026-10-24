import 'package:flutter/material.dart';
import 'package:milo/atoms/blocks/callout.dart';
import 'package:milo/atoms/blocks/checklist.dart';
import 'package:milo/atoms/blocks/delimiter.dart';
import 'package:milo/atoms/blocks/editorjs_utils.dart';
import 'package:milo/atoms/blocks/header.dart';
import 'package:milo/atoms/blocks/image.dart';
import 'package:milo/atoms/blocks/list.dart';
import 'package:milo/atoms/blocks/paragraph.dart';
import 'package:milo/atoms/blocks/unsupported.dart';

export 'package:milo/atoms/blocks/image.dart';

/// Renders a list of Editor.js blocks by picking one widget per block type.
class UIBuilder extends StatelessWidget {
  final List<dynamic>? blocks;
  final Map<String, dynamic>? json;

  const UIBuilder({super.key, this.blocks, this.json});

  @override
  Widget build(BuildContext context) {
    final resolvedBlocks = blocks ?? asList(json?['blocks']);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [for (final block in resolvedBlocks) _buildBlock(block)],
      ),
    );
  }

  Widget _buildBlock(dynamic block) {
    final blockData = asMap(block);
    final type = blockData['type']?.toString().toLowerCase() ?? '';
    final data = asMap(blockData['data']);

    switch (type) {
      case 'header':
        return HeadingWidget(
          text: plainText(data['text']),
          level: data['level'] is num ? (data['level'] as num).toInt() : 1,
        );
      case 'paragraph':
        return ParagraphWidget(text: plainText(data['text']));
      case 'delimiter':
        return const DelimiterWidget();
      case 'image':
        final file = asMap(data['file']);
        return ImageWidget(
          imageUrl: file['url']?.toString() ?? '',
          caption: plainText(data['caption']),
        );
      case 'list':
        final items = asList(data['items']);
        if (data['style'] == 'checklist') {
          return ChecklistWidget(items: items);
        }
        return RecursiveListWidget(
          items: items,
          ordered: data['style'] == 'ordered',
        );
      case 'checklist':
        return ChecklistWidget(items: asList(data['items']));
      case 'callout':
        return CalloutWidget(text: plainText(data['text']));
      default:
        return UnsupportedBlockWidget(type: type, data: data);
    }
  }
}
