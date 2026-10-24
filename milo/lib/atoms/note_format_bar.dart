import 'package:flutter/material.dart';

/// Formatting shortcuts for the note editor. They write the text syntax that
/// the backend turns into Editor.js blocks (aloha/src/notes/notes.format.ts),
/// matching the web editor tools: header, list, checklist and delimiter.
class NoteFormatBar extends StatelessWidget {
  const NoteFormatBar({super.key, required this.controller});

  final TextEditingController controller;

  static final _linePrefix = RegExp(
    r'^(#{1,6} |[-*] \[[ xX]\] |[-*] |\d+[.)] )',
  );

  /// Toggles [prefix] on the line under the cursor. Any other block prefix on
  /// that line is replaced, and the cursor moves with the text.
  static TextEditingValue togglePrefix(TextEditingValue value, String prefix) {
    final text = value.text;
    final cursor = _cursor(value);
    final lineStart = cursor == 0 ? 0 : text.lastIndexOf('\n', cursor - 1) + 1;
    final current =
        _linePrefix.firstMatch(text.substring(lineStart))?.group(0) ?? '';
    final replacement = current == prefix ? '' : prefix;
    final newText = text.replaceRange(
      lineStart,
      lineStart + current.length,
      replacement,
    );
    final newCursor = (cursor + replacement.length - current.length).clamp(
      lineStart,
      newText.length,
    );
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursor),
    );
  }

  /// Inserts a `---` divider on its own line at the cursor.
  static TextEditingValue insertDivider(TextEditingValue value) {
    final text = value.text;
    final cursor = _cursor(value);
    final lineBreak = cursor == 0 || text[cursor - 1] == '\n' ? '' : '\n';
    final insert = '$lineBreak---\n';
    return TextEditingValue(
      text: text.replaceRange(cursor, cursor, insert),
      selection: TextSelection.collapsed(offset: cursor + insert.length),
    );
  }

  static int _cursor(TextEditingValue value) =>
      value.selection.isValid ? value.selection.baseOffset : value.text.length;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      children: [
        _button(Icons.title, 'Heading', (v) => togglePrefix(v, '# ')),
        _button(
          Icons.format_list_bulleted,
          'Bulleted list',
          (v) => togglePrefix(v, '- '),
        ),
        _button(
          Icons.format_list_numbered,
          'Numbered list',
          (v) => togglePrefix(v, '1. '),
        ),
        _button(
          Icons.checklist,
          'Checklist',
          (v) => togglePrefix(v, '- [ ] '),
        ),
        _button(Icons.horizontal_rule, 'Divider', insertDivider),
      ],
    );
  }

  Widget _button(
    IconData icon,
    String tooltip,
    TextEditingValue Function(TextEditingValue) apply,
  ) {
    return IconButton(
      tooltip: tooltip,
      icon: Icon(icon),
      onPressed: () => controller.value = apply(controller.value),
    );
  }
}
