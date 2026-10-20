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
        tasks.add(await _resolveTaskImages(Task.fromApi(Map<String, dynamic>.from(note))));
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

    final signedMap = await _storageService.fetchSignedUrls(pathsToResolve.toList());

    final resolvedBlocks = task.blocks.map((block) {
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
    }).toList(growable: false);

    return Task(
      id: task.id,
      title: task.title,
      description: task.description,
      deltaJson: task.deltaJson,
      folderId: task.folderId,
      isPinned: task.isPinned,
      createdOn: task.createdOn,
      updatedOn: task.updatedOn,
      blocks: resolvedBlocks,
    );
  }
}
