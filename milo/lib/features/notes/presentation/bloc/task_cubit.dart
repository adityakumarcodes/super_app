import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:milo/models/task.dart';
import 'package:milo/services/task_service.dart';

class _CachedTask {
  const _CachedTask(this.task, this.expiresAt);
  final Task task;
  final DateTime expiresAt;
  bool get isFresh => DateTime.now().isBefore(expiresAt);
}

class TaskState {
  const TaskState({this.tasks = const [], this.isLoading = false, this.error});
  final List<Task> tasks;
  final bool isLoading;
  final String? error;
  TaskState copyWith({
    List<Task>? tasks,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) => TaskState(
    tasks: tasks ?? this.tasks,
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : error ?? this.error,
  );
}

class TaskCubit extends Cubit<TaskState> {
  TaskCubit({TaskService? taskService})
    : _taskService = taskService ?? TaskService(),
      super(const TaskState());
  final TaskService _taskService;
  static const _detailCacheDuration = Duration(minutes: 5);
  final Map<int, _CachedTask> _details = {};
  bool _hasLoaded = false;
  int _requestGeneration = 0;

  Future<void> fetchTasks({bool forceRefresh = false}) async {
    if (_hasLoaded && !forceRefresh) return;
    final requestGeneration = ++_requestGeneration;
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final tasks = await _taskService.fetchTasks();
      if (requestGeneration != _requestGeneration) return;
      _hasLoaded = true;
      emit(TaskState(tasks: tasks));
    } catch (error) {
      if (requestGeneration == _requestGeneration) {
        emit(
          state.copyWith(
            isLoading: false,
            error: error.toString().replaceFirst('Exception: ', ''),
          ),
        );
      }
    }
  }

  Future<void> refreshTasks() => fetchTasks(forceRefresh: true);
  Future<Task> fetchTask(int id, {bool forceRefresh = false}) async {
    final cached = _details[id];
    if (!forceRefresh && cached != null && cached.isFresh) return cached.task;
    final requestGeneration = _requestGeneration;
    final task = await _taskService.fetchTask(id);
    if (requestGeneration == _requestGeneration) {
      _details[id] = _CachedTask(
        task,
        DateTime.now().add(_detailCacheDuration),
      );
    }
    return task;
  }

  void clear() {
    _requestGeneration++;
    _details.clear();
    _hasLoaded = false;
    emit(const TaskState());
  }
}
