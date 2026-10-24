import 'package:flutter_test/flutter_test.dart';
import 'package:milo/features/notes/presentation/bloc/task_cubit.dart';
import 'package:milo/models/task.dart';
import 'package:milo/services/task_service.dart';

// A hand-written fake replaces the real service, so tests never hit the
// network. Each test decides what the "server" returns.
class FakeTaskService implements TaskService {
  List<Task> tasks = [];
  Object? error;
  final deletedIds = <int>[];

  @override
  Future<List<Task>> fetchTasks() async {
    if (error != null) throw error!;
    return tasks;
  }

  @override
  Future<Task> fetchTask(int id) async =>
      tasks.firstWhere((task) => task.id == id);

  @override
  Future<Task> createTask({
    required String title,
    required List<Map<String, dynamic>> blocks,
  }) async => Task(id: 99, title: title, blocks: blocks);

  @override
  Future<Task> updateTask(
    int id, {
    required String title,
    List<Map<String, dynamic>>? blocks,
  }) async => Task(id: id, title: title);

  @override
  Future<void> deleteTask(int id) async => deletedIds.add(id);
}

void main() {
  late FakeTaskService service;
  late TaskCubit cubit;

  // setUp runs before every test, so each test starts with fresh objects.
  setUp(() {
    service = FakeTaskService()
      ..tasks = const [
        Task(id: 1, title: 'One'),
        Task(id: 2, title: 'Two'),
      ];
    cubit = TaskCubit(taskService: service);
  });

  tearDown(() => cubit.close());

  test('starts empty', () {
    expect(cubit.state.tasks, isEmpty);
    expect(cubit.state.isLoading, isFalse);
  });

  test('fetchTasks loads notes from the service', () async {
    await cubit.fetchTasks();

    expect(cubit.state.tasks.map((task) => task.id), [1, 2]);
    expect(cubit.state.error, isNull);
  });

  test('fetchTasks shows a readable error when loading fails', () async {
    service.error = Exception('Could not load notes.');

    await cubit.fetchTasks();

    expect(cubit.state.tasks, isEmpty);
    expect(cubit.state.error, 'Could not load notes.');
  });

  test('createTask adds the new note to the top of the list', () async {
    await cubit.fetchTasks();

    await cubit.createTask(title: 'New', blocks: const []);

    expect(cubit.state.tasks.map((task) => task.id), [99, 1, 2]);
  });

  test('updateTask moves the edited note to the top', () async {
    await cubit.fetchTasks();

    await cubit.updateTask(2, title: 'Two v2');

    expect(cubit.state.tasks.map((task) => task.title), ['Two v2', 'One']);
  });

  test('deleteTask removes the note locally and on the server', () async {
    await cubit.fetchTasks();

    await cubit.deleteTask(1);

    expect(service.deletedIds, [1]);
    expect(cubit.state.tasks.map((task) => task.id), [2]);
  });

  test('clear resets the list, e.g. after sign-out', () async {
    await cubit.fetchTasks();

    cubit.clear();

    expect(cubit.state.tasks, isEmpty);
  });
}
