import 'package:flutter/material.dart';
import 'package:milo/models/task.dart';
import 'package:milo/services/task_service.dart';

class _CachedTask {
  const _CachedTask(this.task, this.expiresAt);

  final Task task;
  final DateTime expiresAt;

  bool get isFresh => DateTime.now().isBefore(expiresAt);
}

class TaskProvider extends ChangeNotifier {
  TaskProvider({TaskService? taskService})
    : _taskService = taskService ?? TaskService();

  final TaskService _taskService;
  static const _detailCacheDuration = Duration(minutes: 5);

  List<Task> _tasks = const [];
  final Map<int, _CachedTask> _detailCache = {};
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

  Future<Task> fetchTask(int id, {bool forceRefresh = false}) async {
    final cached = _detailCache[id];
    if (!forceRefresh && cached != null && cached.isFresh) {
      return cached.task;
    }

    final requestGeneration = _requestGeneration;
    final task = await _taskService.fetchTask(id);
    if (requestGeneration == _requestGeneration) {
      _detailCache[id] = _CachedTask(
        task,
        DateTime.now().add(_detailCacheDuration),
      );
    }
    return task;
  }

  void invalidateTask(int id) => _detailCache.remove(id);

  void clear() {
    _requestGeneration++;
    _tasks = const [];
    _detailCache.clear();
    _isLoading = false;
    _error = null;
    _hasLoaded = false;
    notifyListeners();
  }
}
