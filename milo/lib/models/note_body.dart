/// Converts between Editor.js blocks and the plain text used by the mobile
/// note editor. Paragraph text is stored as HTML, so it is escaped on save.
abstract final class NoteBody {
  static final _lineBreak = RegExp(r'<br\s*/?>', caseSensitive: false);
  static final _tag = RegExp(r'<[^>]*>');
  static final _blankLine = RegExp(r'\n\s*\n');

  /// Returns the note as plain text, or null when it has content that plain
  /// text editing would lose (images, lists, formatting).
  static String? toText(List<Map<String, dynamic>> blocks) {
    final paragraphs = <String>[];
    for (final block in blocks) {
      final data = block['data'];
      final html = data is Map ? data['text'] : null;
      if (block['type'] != 'paragraph' || html is! String) return null;

      final text = html.replaceAll(_lineBreak, '\n');
      if (_tag.hasMatch(text)) return null;
      paragraphs.add(_unescape(text));
    }
    return paragraphs.join('\n\n');
  }

  static List<Map<String, dynamic>> toBlocks(String text) {
    return text
        .split(_blankLine)
        .map((paragraph) => paragraph.trim())
        .where((paragraph) => paragraph.isNotEmpty)
        .map(
          (paragraph) => <String, dynamic>{
            'type': 'paragraph',
            'data': {'text': _escape(paragraph).replaceAll('\n', '<br>')},
          },
        )
        .toList(growable: false);
  }

  static String _escape(String text) => text
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');

  static String _unescape(String text) => text
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&amp;', '&');
}
