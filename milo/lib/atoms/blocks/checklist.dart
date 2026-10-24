import 'package:flutter/material.dart';
import 'package:milo/atoms/blocks/editorjs_utils.dart';

/// Editor.js `list` block with `checklist` style. Ticking a box only changes
/// what is shown; it is not saved.
class ChecklistWidget extends StatefulWidget {
  final List<dynamic> items;

  const ChecklistWidget({super.key, required this.items});

  @override
  State<ChecklistWidget> createState() => _ChecklistWidgetState();
}

class _ChecklistWidgetState extends State<ChecklistWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.items
          .map((item) {
            final itemData = asMap(item);
            final meta = asMap(itemData['meta']);
            final children = asList(itemData['items']);

            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Column(
                children: [
                  CheckboxListTile(
                    value: meta['checked'] == true,
                    onChanged: (value) {
                      setState(() {
                        meta['checked'] = value ?? false;
                      });
                    },
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: SelectableText(
                      plainText(itemData['content'] ?? item),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  if (children.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 24),
                      child: ChecklistWidget(items: children),
                    ),
                ],
              ),
            );
          })
          .toList(growable: false),
    );
  }
}
