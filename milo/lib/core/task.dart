/// A note as returned by the unified notes API. The backend already resolves
/// image URLs and provides [content], so the app only renders.
class Task {
  final int id;
  final String title;

  /// Signed, display-ready cover image URL.
  final String? coverUrl;

  /// The note as editable text (see aloha/src/notes/notes.format.ts), or null
  /// when it has content that cannot be edited as text.
  final String? content;
  final String createdOn;
  final String updatedOn;
  final List<Map<String, dynamic>> blocks;

  const Task({
    required this.id,
    required this.title,
    this.coverUrl,
    this.content,
    this.createdOn = '',
    this.updatedOn = '',
    this.blocks = const [],
  });

  factory Task.fromApi(Map<String, dynamic> json) {
    return Task(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '',
      coverUrl: json['coverUrl'] as String?,
      content: json['content'] as String?,
      createdOn: json['createdAt'] as String? ?? '',
      updatedOn: json['updatedAt'] as String? ?? '',
      blocks: _parseBlocks(json['blocks']),
    );
  }

  static List<Map<String, dynamic>> _parseBlocks(dynamic value) {
    if (value is! List) return const [];

    return value
        .whereType<Map>()
        .map((block) => Map<String, dynamic>.from(block))
        .toList(growable: false);
  }

  String get displayTitle {
    final trimmedTitle = title.trim();
    return trimmedTitle.isEmpty ? 'Untitled note' : trimmedTitle;
  }
}
