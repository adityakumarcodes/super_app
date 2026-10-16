import 'package:flutter/material.dart';
import 'package:milo/models/task.dart';
import 'package:milo/services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  TaskProvider({TaskService? taskService})
    : _taskService = taskService ?? TaskService();

  final TaskService _taskService;
  List<Task> _tasks = const [];
  bool _isLoading = false;
  String? _error;
  bool _hasLoaded = false;
  int _requestGeneration = 0;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchTasks({bool forceRefresh = false}) async {
    if (_hasLoaded && !forceRefresh) return;
    final requestGeneration = ++_requestGeneration;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final tasks = await _taskService.fetchTasks();
      if (requestGeneration != _requestGeneration) return;
      _tasks = tasks;
      _hasLoaded = true;
    } catch (error) {
      if (requestGeneration != _requestGeneration) return;
      _error = error.toString().replaceFirst('Exception: ', '');
    } finally {
      if (requestGeneration == _requestGeneration) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> refreshTasks() => fetchTasks(forceRefresh: true);

  void clear() {
    _requestGeneration++;
    _tasks = const [];
    _isLoading = false;
    _error = null;
    _hasLoaded = false;
    notifyListeners();
  }
}
