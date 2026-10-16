import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:milo/models/task.dart';
import 'package:milo/services/task_database.dart';

class TaskProvider extends ChangeNotifier {
  List<Task>? _tasks;
  bool _isLoading = false;
  String? _error;

  List<Task>? get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchTasks({bool forceRefresh = false}) async {
    if (_tasks != null && !forceRefresh) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final rows = await TaskDatabase.instance.getTasks();

      _tasks = rows.map((row) {
        final delta = jsonDecode(row['delta_json'] as String) as List;

        return Task(
          id: row['id'] as int,
          title: (row['title'] as String?) ?? '',
          content: {
            'ops': delta,
            'description': (row['description'] as String?) ?? '',
          },
          createdOn: row['created_at'] as String,
          statusFlag: (row['is_pinned'] as int) == 1 ? 'pinned' : 'active',
        );
      }).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Force the Notes list to reload from SQLite.
  Future<void> refreshTasks() {
    return fetchTasks(forceRefresh: true);
  }
}
