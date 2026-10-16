class NoteFolder {
  final int id;
  final String name;
  final String createdOn;
  final String updatedOn;

  const NoteFolder({
    required this.id,
    required this.name,
    required this.createdOn,
    required this.updatedOn,
  });

  factory NoteFolder.fromDatabase(Map<String, Object?> row) {
    return NoteFolder(
      id: row['id'] as int,
      name: row['name'] as String,
      createdOn: (row['created_at'] as String?) ?? '',
      updatedOn: (row['updated_at'] as String?) ?? '',
    );
  }
}
