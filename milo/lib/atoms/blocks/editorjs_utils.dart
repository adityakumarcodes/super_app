/// Small helpers for reading loosely typed Editor.js block JSON.
library;

Map<String, dynamic> asMap(dynamic value) {
  if (value is! Map) return const {};
  return Map<String, dynamic>.from(value);
}

List<dynamic> asList(dynamic value) => value is List ? value : const [];

/// Turns Editor.js inline HTML into display text: line breaks become `\n`,
/// other tags are dropped and common entities are decoded.
String plainText(dynamic value) {
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
