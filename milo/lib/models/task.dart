class Task {
  final int id;
  final String title;
  final String description;
  final String deltaJson;
  final int? folderId;
  final bool isPinned;
  final String createdOn;
  final String updatedOn;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.deltaJson,
    required this.folderId,
    required this.isPinned,
    required this.createdOn,
    required this.updatedOn,
  });

  factory Task.fromDatabase(Map<String, Object?> row) {
    return Task(
      id: row['id'] as int,
      title: (row['title'] as String?) ?? '',
      description: (row['description'] as String?) ?? '',
      deltaJson: (row['delta_json'] as String?) ?? '[]',
      folderId: row['folder_id'] as int?,
      isPinned: (row['is_pinned'] as int? ?? 0) == 1,
      createdOn: (row['created_at'] as String?) ?? '',
      updatedOn: (row['updated_at'] as String?) ?? '',
    );
  }

  String get displayTitle {
    final trimmedTitle = title.trim();
    return trimmedTitle.isEmpty ? 'Untitled note' : trimmedTitle;
  }

  String get preview => description.replaceAll(RegExp(r'\s+'), ' ').trim();
}
