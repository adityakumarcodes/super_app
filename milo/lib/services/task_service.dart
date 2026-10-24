import 'package:flutter_better_auth/flutter_better_auth.dart';
import 'package:milo/services/app_config.dart';
import 'package:milo/models/task.dart';
import 'package:milo/services/storage_service.dart';
import 'package:milo/models/note_image_resolver.dart';

class TaskService {
  final StorageService _storageService = StorageService();

  Future<List<Task>> fetchTasks() async {
    try {
      final response = await FlutterBetterAuth.dioClient
          .get<List<dynamic>>(AppConfig.notesUrl)
          .timeout(AppConfig.requestTimeout);
      final notes = response.data;
      if (notes == null) throw const FormatException('Missing notes response.');

      final tasks = <Task>[];
      for (final note in notes) {
        if (note is! Map) {
          throw const FormatException('Invalid note response.');
        }
        tasks.add(
          await _resolveTaskImages(
            Task.fromApi(Map<String, dynamic>.from(note)),
          ),
        );
      }

      return tasks;
    } catch (_) {
      throw Exception(
        'Could not load notes. Check your connection and try again.',
      );
    }
  }

  Future<Task> fetchTask(int id) async {
    try {
      final response = await FlutterBetterAuth.dioClient
          .get<Map<String, dynamic>>('${AppConfig.notesUrl}$id')
          .timeout(AppConfig.requestTimeout);
      final note = response.data;
      if (note == null) {
        throw const FormatException('Missing note response.');
      }

      final task = Task.fromApi(note);
      return await _resolveTaskImages(task);
    } catch (_) {
      throw Exception(
        'Could not load note details. Check your connection and try again.',
      );
    }
  }

  Future<Task> createTask({
    required String title,
    required List<Map<String, dynamic>> blocks,
  }) async {
    try {
      final response = await FlutterBetterAuth.dioClient
          .post<Map<String, dynamic>>(
            AppConfig.notesUrl,
            data: {'title': title, 'blocks': blocks},
          )
          .timeout(AppConfig.requestTimeout);
      return Task.fromApi(response.data!);
    } catch (_) {
      throw Exception('Could not save the note. Try again.');
    }
  }

  /// Leave [blocks] null to keep the note's existing content.
  Future<Task> updateTask(
    int id, {
    required String title,
    List<Map<String, dynamic>>? blocks,
  }) async {
    try {
      final response = await FlutterBetterAuth.dioClient
          .patch<Map<String, dynamic>>(
            '${AppConfig.notesUrl}$id',
            data: {'title': title, 'blocks': blocks},
          )
          .timeout(AppConfig.requestTimeout);
      return Task.fromApi(response.data!);
    } catch (_) {
      throw Exception('Could not save the note. Try again.');
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      await FlutterBetterAuth.dioClient
          .delete<void>('${AppConfig.notesUrl}$id')
          .timeout(AppConfig.requestTimeout);
    } catch (_) {
      throw Exception('Could not delete the note. Try again.');
    }
  }

  Future<Task> _resolveTaskImages(Task task) async {
    if (task.blocks.isEmpty) return task;

    final pathsToResolve = <String>{};
    for (final block in task.blocks) {
      final blockData = block;
      final type = blockData['type']?.toString().toLowerCase() ?? '';
      if (type != 'image') continue;
      final data = blockData['data'];
      if (data is! Map) continue;
      final file = data['file'];
      if (file is! Map) continue;
      final path = extractStoragePath(Map<String, dynamic>.from(file));
      if (path != null) pathsToResolve.add(path);
    }

    if (pathsToResolve.isEmpty) return task;

    final signedMap = await _storageService.fetchSignedUrls(
      pathsToResolve.toList(),
    );

    final resolvedBlocks = task.blocks
        .map((block) {
          final blockData = Map<String, dynamic>.from(block);
          final type = blockData['type']?.toString().toLowerCase() ?? '';
          if (type != 'image') return blockData;
          final data = blockData['data'];
          if (data is! Map) return blockData;
          final file = Map<String, dynamic>.from(data['file'] as Map? ?? {});
          final path = extractStoragePath(file);
          if (path != null && signedMap.containsKey(path)) {
            file['url'] = signedMap[path];
            // keep path for reference
            final newData = Map<String, dynamic>.from(data);
            newData['file'] = file;
            blockData['data'] = newData;
            return blockData;
          }
          return blockData;
        })
        .toList(growable: false);

    return task.copyWith(blocks: resolvedBlocks);
  }
}
