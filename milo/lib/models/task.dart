class Task {
  final int id;
  final String title;
  final String description;
  final String deltaJson;
  final String? imageUrl;
  final int? folderId;
  final bool isPinned;
  final String createdOn;
  final String updatedOn;
  final List<Map<String, dynamic>> blocks;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.deltaJson,
    this.imageUrl,
    required this.folderId,
    required this.isPinned,
    required this.createdOn,
    required this.updatedOn,
    this.blocks = const [],
  });

  factory Task.fromDatabase(Map<String, Object?> row) {
    return Task(
      id: row['id'] as int,
      title: (row['title'] as String?) ?? '',
      description: (row['description'] as String?) ?? '',
      deltaJson: (row['delta_json'] as String?) ?? '[]',
      imageUrl: null,
      folderId: row['folder_id'] as int?,
      isPinned: (row['is_pinned'] as int? ?? 0) == 1,
      createdOn: (row['created_at'] as String?) ?? '',
      updatedOn: (row['updated_at'] as String?) ?? '',
      blocks: const [],
    );
  }

  factory Task.fromApi(Map<String, dynamic> json) {
    return Task(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      deltaJson: '[]',
      imageUrl: json['imageUrl'] as String?,
      folderId: null,
      isPinned: false,
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

  String get preview => description.replaceAll(RegExp(r'\s+'), ' ').trim();
}
