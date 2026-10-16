import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class TaskDatabase {
  TaskDatabase._();

  static final TaskDatabase instance = TaskDatabase._();

  static const String _databaseName = 'aloha_tasks.db';
  static const String _tasksTable = 'tasks';
  static const String _foldersTable = 'folders';
  static const int _databaseVersion = 2;

  late final Future<Database> _database = _openDatabase();

  Future<Database> get database => _database;

  Future<Database> _openDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _databaseName);

    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await _createFoldersTable(db);
        await _createTasksTable(db);
        await _seedInitialFolders(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createFoldersTable(db);
          await db.execute(
            'ALTER TABLE $_tasksTable ADD COLUMN folder_id INTEGER',
          );
          await _seedInitialFolders(db);
        }
      },
    );
  }

  Future<void> _createFoldersTable(DatabaseExecutor db) {
    return db.execute('''
      CREATE TABLE IF NOT EXISTS $_foldersTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL COLLATE NOCASE UNIQUE,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createTasksTable(DatabaseExecutor db) {
    return db.execute('''
      CREATE TABLE $_tasksTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL DEFAULT '',
        description TEXT NOT NULL DEFAULT '',
        delta_json TEXT NOT NULL,
        folder_id INTEGER,
        is_pinned INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _seedInitialFolders(DatabaseExecutor db) async {
    final now = DateTime.now().toIso8601String();
    for (final name in const ['My Notes', 'My Skills', 'TODOS']) {
      await db.insert(_foldersTable, {
        'name': name,
        'created_at': now,
        'updated_at': now,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  Future<List<Map<String, Object?>>> getTasks() async {
    final db = await database;
    return db.query(_tasksTable, orderBy: 'is_pinned DESC, updated_at DESC');
  }

  Future<Map<String, Object?>?> getTask(int id) async {
    final db = await database;
    final results = await db.query(
      _tasksTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return results.isEmpty ? null : results.first;
  }

  Future<List<Map<String, Object?>>> getFolders() async {
    final db = await database;
    return db.query(_foldersTable, orderBy: 'name COLLATE NOCASE ASC');
  }

  Future<int> insertTask({
    required String title,
    required String description,
    required String deltaJson,
    required int? folderId,
    required bool isPinned,
  }) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    return db.transaction<int>((transaction) async {
      await _assertFolderExists(transaction, folderId);
      return transaction.insert(_tasksTable, {
        'title': title,
        'description': description,
        'delta_json': deltaJson,
        'folder_id': folderId,
        'is_pinned': isPinned ? 1 : 0,
        'created_at': now,
        'updated_at': now,
      }, conflictAlgorithm: ConflictAlgorithm.abort);
    });
  }

  Future<int> updateTask({
    required int id,
    required String title,
    required String description,
    required String deltaJson,
    required int? folderId,
    required bool isPinned,
  }) async {
    final db = await database;
    return db.transaction<int>((transaction) async {
      await _assertFolderExists(transaction, folderId);
      return transaction.update(
        _tasksTable,
        {
          'title': title,
          'description': description,
          'delta_json': deltaJson,
          'folder_id': folderId,
          'is_pinned': isPinned ? 1 : 0,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  Future<int> deleteTask(int id) => deleteTasks([id]);

  Future<int> deleteTasks(Iterable<int> taskIds) async {
    final ids = taskIds.toSet().toList();
    if (ids.isEmpty) return 0;

    final db = await database;
    return db.delete(
      _tasksTable,
      where: 'id IN (${_placeholders(ids.length)})',
      whereArgs: ids,
    );
  }

  Future<int> moveTasks(Iterable<int> taskIds, int? folderId) async {
    final ids = taskIds.toSet().toList();
    if (ids.isEmpty) return 0;

    final db = await database;
    return db.transaction<int>((transaction) async {
      await _assertFolderExists(transaction, folderId);
      return transaction.update(
        _tasksTable,
        {'folder_id': folderId, 'updated_at': DateTime.now().toIso8601String()},
        where: 'id IN (${_placeholders(ids.length)})',
        whereArgs: ids,
      );
    });
  }

  Future<int> copyTasks(Iterable<int> taskIds, int? folderId) async {
    final ids = taskIds.toSet().toList();
    if (ids.isEmpty) return 0;

    final db = await database;
    return db.transaction<int>((transaction) async {
      await _assertFolderExists(transaction, folderId);
      final sourceTasks = await transaction.query(
        _tasksTable,
        where: 'id IN (${_placeholders(ids.length)})',
        whereArgs: ids,
      );
      final now = DateTime.now().toIso8601String();
      var copiedCount = 0;

      for (final task in sourceTasks) {
        final title = (task['title'] as String? ?? '').trim();
        await transaction.insert(_tasksTable, {
          'title': title.isEmpty ? 'Untitled note (Copy)' : '$title (Copy)',
          'description': task['description'] as String? ?? '',
          'delta_json': task['delta_json'] as String? ?? '[]',
          'folder_id': folderId,
          'is_pinned': 0,
          'created_at': now,
          'updated_at': now,
        });
        copiedCount++;
      }
      return copiedCount;
    });
  }

  Future<int> insertFolder(String name) async {
    final cleanedName = _validateFolderName(name);
    final db = await database;
    final now = DateTime.now().toIso8601String();
    return db.insert(_foldersTable, {
      'name': cleanedName,
      'created_at': now,
      'updated_at': now,
    }, conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future<int> updateFolder(int id, String name) async {
    final cleanedName = _validateFolderName(name);
    final db = await database;
    return db.update(
      _foldersTable,
      {'name': cleanedName, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteFolder(int id) async {
    final db = await database;
    await db.transaction((transaction) async {
      // Keep notes intact when their folder is removed.
      await transaction.update(
        _tasksTable,
        {'folder_id': null, 'updated_at': DateTime.now().toIso8601String()},
        where: 'folder_id = ?',
        whereArgs: [id],
      );
      await transaction.delete(_foldersTable, where: 'id = ?', whereArgs: [id]);
    });
  }

  String _validateFolderName(String name) {
    final cleanedName = name.trim();
    if (cleanedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'A folder name is required.');
    }
    return cleanedName;
  }

  Future<void> _assertFolderExists(DatabaseExecutor db, int? folderId) async {
    if (folderId == null) return;

    final folders = await db.query(
      _foldersTable,
      columns: ['id'],
      where: 'id = ?',
      whereArgs: [folderId],
      limit: 1,
    );
    if (folders.isEmpty) {
      throw StateError('The selected folder no longer exists.');
    }
  }

  String _placeholders(int count) => List.filled(count, '?').join(', ');
}
