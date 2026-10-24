class Task {
  final int id;
  final String title;
  final String? imageUrl;
  final String createdOn;
  final String updatedOn;
  final List<Map<String, dynamic>> blocks;

  const Task({
    required this.id,
    required this.title,
    this.imageUrl,
    this.createdOn = '',
    this.updatedOn = '',
    this.blocks = const [],
  });

  factory Task.fromApi(Map<String, dynamic> json) {
    return Task(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      createdOn: json['createdAt'] as String? ?? '',
      updatedOn: json['updatedAt'] as String? ?? '',
      blocks: _parseBlocks(json['blocks']),
    );
  }

  Task copyWith({List<Map<String, dynamic>>? blocks}) {
    return Task(
      id: id,
      title: title,
      imageUrl: imageUrl,
      createdOn: createdOn,
      updatedOn: updatedOn,
      blocks: blocks ?? this.blocks,
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
