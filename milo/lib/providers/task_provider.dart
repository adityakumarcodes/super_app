import 'package:flutter/material.dart';
import 'package:milo/models/note_folder.dart';
import 'package:milo/models/task.dart';
import 'package:milo/services/task_database.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = const [];
  List<NoteFolder> _folders = const [];
  bool _isLoading = false;
  String? _error;
  bool _hasLoaded = false;

  List<Task> get tasks => _tasks;
  List<NoteFolder> get folders => _folders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  NoteFolder? folderById(int? folderId) {
    if (folderId == null) return null;
    for (final folder in _folders) {
      if (folder.id == folderId) return folder;
    }
    return null;
  }

  Future<void> fetchTasks({bool forceRefresh = false}) async {
    if (_hasLoaded && !forceRefresh) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _reload();
      _hasLoaded = true;
    } catch (error) {
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshTasks() => fetchTasks(forceRefresh: true);

  Future<int> saveTask({
    int? id,
    required String title,
    required String description,
    required String deltaJson,
    required int? folderId,
    required bool isPinned,
  }) async {
    final taskId = id == null
        ? await TaskDatabase.instance.insertTask(
            title: title,
            description: description,
            deltaJson: deltaJson,
            folderId: folderId,
            isPinned: isPinned,
          )
        : await _updateExistingTask(
            id: id,
            title: title,
            description: description,
            deltaJson: deltaJson,
            folderId: folderId,
            isPinned: isPinned,
          );
    await _reload();
    return taskId;
  }

  Future<int> _updateExistingTask({
    required int id,
    required String title,
    required String description,
    required String deltaJson,
    required int? folderId,
    required bool isPinned,
  }) async {
    final updatedRows = await TaskDatabase.instance.updateTask(
      id: id,
      title: title,
      description: description,
      deltaJson: deltaJson,
      folderId: folderId,
      isPinned: isPinned,
    );
    if (updatedRows == 0) {
      throw StateError('This note was deleted before it could be saved.');
    }
    return id;
  }

  Future<int> deleteTasks(Iterable<int> taskIds) async {
    final deletedRows = await TaskDatabase.instance.deleteTasks(taskIds);
    await _reload();
    return deletedRows;
  }

  Future<int> moveTasks(Iterable<int> taskIds, int? folderId) async {
    final movedRows = await TaskDatabase.instance.moveTasks(taskIds, folderId);
    await _reload();
    return movedRows;
  }

  Future<int> copyTasks(Iterable<int> taskIds, int? folderId) async {
    final copiedRows = await TaskDatabase.instance.copyTasks(taskIds, folderId);
    await _reload();
    return copiedRows;
  }

  Future<int> createFolder(String name) async {
    final folderId = await TaskDatabase.instance.insertFolder(name);
    await _reload();
    return folderId;
  }

  Future<void> renameFolder(int id, String name) async {
    await TaskDatabase.instance.updateFolder(id, name);
    await _reload();
  }

  Future<void> deleteFolder(int id) async {
    await TaskDatabase.instance.deleteFolder(id);
    await _reload();
  }

  Future<void> _reload() async {
    final results = await Future.wait([
      TaskDatabase.instance.getTasks(),
      TaskDatabase.instance.getFolders(),
    ]);
    _tasks = results[0]
        .cast<Map<String, Object?>>()
        .map(Task.fromDatabase)
        .toList();
    _folders = results[1]
        .cast<Map<String, Object?>>()
        .map(NoteFolder.fromDatabase)
        .toList();
    _error = null;
    notifyListeners();
  }
}
