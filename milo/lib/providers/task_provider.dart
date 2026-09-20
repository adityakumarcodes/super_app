import 'package:flutter/material.dart';
import 'package:milo/models/task.dart';
import 'package:milo/services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  List<Task>? _tasks;
  bool _isLoading = false;
  String? _error;

  List<Task>? get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchTasks() async {
    if (_tasks != null) return; // Cache: don't refetch if already loaded

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tasks = await TaskService().fetchActiveTasks();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
