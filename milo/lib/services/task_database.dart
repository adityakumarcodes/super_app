import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class TaskDatabase {
  TaskDatabase._();

  static final TaskDatabase instance = TaskDatabase._();

  static const String _databaseName = 'aloha_tasks.db';
  static const String _tableName = 'tasks';

  late final Future<Database> _database = _openDatabase();

  Future<Database> get database => _database;

  Future<Database> _openDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _databaseName);

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL DEFAULT '',
            description TEXT NOT NULL DEFAULT '',
            delta_json TEXT NOT NULL,
            is_pinned INTEGER NOT NULL DEFAULT 0,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  /// Inserts a task and returns its generated database ID.
  Future<int> insertTask({
    required String title,
    required String description,
    required String deltaJson,
    required bool isPinned,
  }) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    return db.insert(_tableName, {
      'title': title,
      'description': description,
      'delta_json': deltaJson,
      'is_pinned': isPinned ? 1 : 0,
      'created_at': now,
      'updated_at': now,
    }, conflictAlgorithm: ConflictAlgorithm.abort);
  }

  /// Retrieves all tasks, with pinned tasks first.
  Future<List<Map<String, Object?>>> getTasks() async {
    final db = await database;

    return db.query(_tableName, orderBy: 'is_pinned DESC, updated_at DESC');
  }

  /// Retrieves one task by its database ID.
  Future<Map<String, Object?>?> getTask(int id) async {
    final db = await database;

    final results = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    return results.isEmpty ? null : results.first;
  }

  /// Deletes a task by its database ID.
  Future<int> deleteTask(int id) async {
    final db = await database;

    return db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }
}
