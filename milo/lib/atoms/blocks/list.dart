import 'package:flutter/material.dart';
import 'package:milo/atoms/blocks/editorjs_utils.dart';

/// Editor.js `list` block with `unordered` or `ordered` style; nested items
/// are rendered recursively with extra indentation.
class RecursiveListWidget extends StatelessWidget {
  final List<dynamic> items;
  final bool ordered;
  final int indentLevel;

  const RecursiveListWidget({
    super.key,
    required this.items,
    this.ordered = false,
    this.indentLevel = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(items.length, (index) {
        final item = items[index];
        final itemData = asMap(item);
        final content = itemData.isEmpty ? item : itemData['content'];
        final children = asList(itemData['items']);

        return Padding(
          padding: EdgeInsets.only(left: 16.0 * indentLevel, bottom: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ordered ? '${index + 1}.' : '•',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SelectableText(
                      plainText(content),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
              if (children.isNotEmpty)
                RecursiveListWidget(
                  items: children,
                  ordered: ordered,
                  indentLevel: indentLevel + 1,
                ),
            ],
          ),
        );
      }),
    );
  }
}
